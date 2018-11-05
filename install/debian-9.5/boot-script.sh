DEBIAN_FRONTEND=noninteractive
apt update --yes
apt upgrade --yes
apt dist-upgrade --yes
apt install --yes git
git clone --depth=1 https://github.com/ktachibana/russ.git /russ
bash /russ/install/debian-9.5/install.sh <SECRET_KEY_BASE here>
