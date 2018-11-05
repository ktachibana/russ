#!/usr/bin/env bash

SECRET_KEY_BASE=$1

apt install --yes postgresql build-essential libssl-dev libreadline-dev zlib1g-dev libxml2-dev libxslt-dev nodejs yarn

git clone https://github.com/rbenv/ruby-build.git /ruby-build
PREFIX=/usr/local /ruby-build/install.sh
/usr/local/bin/ruby-build `cat /russ/.ruby-version` /usr/local
gem install bundler --version=1.16.1

cd /russ/
yarn install
bundle install

install -m 644 russ.service russ-crawler.service /etc/systemd/system
install -m 600 russ.env /russ/russ.env
echo "SECRET_KEY_BASE=$SECRET_KEY_BASE" >> /russ/russ.env

systemctl enable russ
systemctl enable russ-crawler

reboot
