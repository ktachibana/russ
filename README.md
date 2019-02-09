## Russ

RSS Reader

## install on LightSail ubuntu

sudo apt update
sudo apt upgrade      -y -o Dpkg::Options::="--force-confold"
sudo apt dist-upgrade -y -o Dpkg::Options::="--force-confold"
sudo apt install      -y -o Dpkg::Options::="--force-confold" docker.io docker-compose git
git clone --depth=1 https://github.com/ktachibana/russ.git
echo 'SECRET_KEY_BASE=<your secret key>' > russ/docker-app.env
sudo reboot

cd russ
sudo docker-compose pull
sudo docker-compose up -d

^d
scp -i ~/.ssh/LightSail*.pem <dump_file> ubuntu@<IP>:
ssh -i ~/.ssh/LightSail*.pem <IP>
sudo docker-compose run --rm db-oneoff pg_restore --verbose --no-acl --no-owner -h database -U postgres -d postgres < <dump_file>
