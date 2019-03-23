#!/usr/bin/env bash

RAILS_MASTER_KEY='$1'
DB_DUMP_URL="$2"

# @see https://docs.docker.com/install/linux/docker-ce/debian/

sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker admin
sudo curl -s -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

cd /home/admin
wget https://raw.githubusercontent.com/ktachibana/russ/master/docker-compose.yml
echo "RAILS_MASTER_KEY=$RAILS_MASTER_KEY" > docker-app.env
wget --quiet --output-document initial.dump $DB_DUMP_URL

docker-compose up --quiet-pull --no-build --detach
