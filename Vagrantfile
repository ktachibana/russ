# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = 'trusty'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.network 'private_network', ip: '192.168.33.10'
  config.vm.provision 'shell', inline: <<-SHELL
    echo 'DOCKER_OPTS="-H tcp://0.0.0.0:2375"' > /etc/default/docker
  SHELL
  config.vm.provision 'docker'
end
