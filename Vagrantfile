# -*- mode: ruby -*-

Vagrant.configure("2") do |config|

    config.vm.define "librenms" do |box|
        box.vm.box = "ubuntu/bionic64"
        box.vm.box_version = "20200225.0.0"
        box.vm.hostname = 'librenms.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.gui = false
            vb.memory = 1280
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.152.10"
        box.vm.provision "shell", path: "vagrant/debian.sh"
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", inline: "/opt/puppetlabs/bin/puppet apply /vagrant/vagrant/librenms.pp"
    end
end
