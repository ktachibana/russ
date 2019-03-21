#!/usr/bin/env bash

RAILS_MASTER_KEY=$1

RAILS_ENV=production
DEBIAN_FRONTEND=noninteractive
curl -sL https://deb.nodesource.com/setup_11.x | bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

apt update --yes
apt upgrade --yes
apt dist-upgrade --yes

apt install --yes git postgresql libpq-dev build-essential libssl-dev libreadline-dev zlib1g-dev libxml2-dev libxslt-dev nodejs yarn nginx
git clone --depth=1 https://github.com/ktachibana/russ.git /russ

git clone https://github.com/rbenv/ruby-build.git /ruby-build
PREFIX=/usr/local /ruby-build/install.sh
/usr/local/bin/ruby-build `cat /russ/.ruby-version` /usr/local
gem install bundler --version=1.16.1

cd /russ/

yarn install
bundle install --with=production

pushd install/debian-9.5
install -m 644 russ.service russ-crawler.service /etc/systemd/system
install -m 644 nginx.conf /etc/nginx/site-available/default
install -m 600 russ.env /russ/russ.env
popd

echo $RAILS_MASTER_KEY >> /russ/config/master.key
bundle exec rails db:create

systemctl enable russ
systemctl enable russ-crawler

reboot
