# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "debian/jessie64"

  # Share root directory to /vagrant using www-data permission
  config.vm.synced_folder "./", "/vagrant", type: "virtualbox", owner: "www-data", group: "www-data"

  # Set cpu and memory
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end

  # Set up private network
  # efault.vm.network "private_network", ip: "192.168.33.10"

  # Forward 8080 -> 80 and 8443 -> 443
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 8443

  # Enable docker provision
  config.vm.provision :docker
  config.vm.provision :docker_compose, yml: ["/vagrant/docker-compose.yml", "/vagrant/docker-compose.override.yml"], run: "always"

  # Install docker 1.7.1 compose - this will replace the one from :docker-compose
  config.vm.provision "shell", inline: <<-SHELL
    # Update docker compose
    if [[ "$(docker-compose --version)" != *1.7.1* ]]; then
      curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose
    fi
  SHELL
end

