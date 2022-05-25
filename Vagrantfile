# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/impish64"
    config.vm.network "private_network", ip: "192.168.33.10"
    #config.vm.network :forwarded_port, guest: 22, host: 1234
    config.vm.hostname = "webdev.impish64"
    config.vm.boot_timeout = 300
    
    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 1
    end
    
    config.vm.synced_folder ".", "/var/www", create:true, :mount_options => ["dmode=777", "fmode=666"]
    config.vm.provision "shell", path: "provision.sh"
    config.vm.provision "shell", :run => 'always', inline: <<-SHELL
        
    SHELL

end
