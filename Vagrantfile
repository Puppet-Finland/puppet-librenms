# -*- mode: ruby -*-

Vagrant.configure("2") do |config|
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = false
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = false

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
    box.vm.provision "shell", inline: "/usr/bin/apt-get update"
    box.vm.provision "shell",
      inline: "/opt/puppetlabs/bin/puppet apply /vagrant/vagrant/hosts.pp --modulepath=/vagrant/modules",
      env: {  'FACTER_my_host': 'librenms.vagrant.example.lan',
              'FACTER_my_ip': '192.168.152.10' }
    box.vm.provision "shell",
      inline: "/opt/puppetlabs/bin/puppet apply /vagrant/vagrant/librenms.pp --modulepath=/vagrant/modules",
      env: {  # Version 1.65. Tags do not seem to work correctly with
              # our particular version of puppetlabs-vcsrepo.
              'FACTER_librenms_version':           '8a6de3ef233421be1962efb896cafc96e8f3dc20',
              'FACTER_librenms_extra_config_file': '/vagrant/vagrant/librenms-extra-config.php',
              'FACTER_servermonitor':              'hostmaster@vagrant.example.lan',
              'FACTER_db_pass':                    'vagrant',
              'FACTER_db_root_pass':               'vagrant',
              'FACTER_admin_pass':                 'vagrant',
              'FACTER_admin_email':                'hostmaster@vagrant.example.lan' }
    box.vm.provision "shell",
      inline: "/opt/puppetlabs/bin/puppet apply /vagrant/vagrant/snmp.pp --modulepath=/vagrant/modules",
      env: {  'FACTER_servermonitor': 'hostmaster@vagrant.example.lan',
              'FACTER_snmp_user':     'librenms',
              # The SNMP password will have to be long enough or you will run
              # into odd issues
              'FACTER_snmp_pass':     'vagrant123' }
    # Work around permission issues reported by validate.php that are very
    # tricky to fix with Puppet which wants to check and maintain state.
    box.vm.provision "shell", path: "vagrant/cleanup.sh"
  end

  config.vm.define "librenms-focal" do |box|
    box.vm.box = "ubuntu/focal64"
    box.vm.box_version = "20210125.0.1"
    box.vm.hostname = 'librenms-focal.vagrant.example.lan'
    box.hostmanager.enabled = true
    box.hostmanager.aliases = %w(librenms-focal.vagrant.example.lan)
    box.vm.provider 'virtualbox' do |vb|
      vb.gui = false
      vb.memory = 1280
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--hpet", "on"]
    end
    box.vm.network "private_network", ip: "192.168.152.11"
    box.vm.provision "shell", path: "vagrant/debian.sh"
    box.vm.provision "shell", path: "vagrant/common.sh"
    box.vm.provision "shell", inline: "/usr/bin/apt-get update"
    box.vm.provision "shell",
      inline: "/opt/puppetlabs/bin/puppet apply /vagrant/vagrant/hosts.pp --modulepath=/vagrant/modules",
      env: {  'FACTER_my_host': 'librenms-focal.vagrant.example.lan',
              'FACTER_my_ip': '192.168.152.11' }
    box.vm.provision "shell",
      inline: "/opt/puppetlabs/bin/puppet apply /vagrant/vagrant/librenms.pp --modulepath=/vagrant/modules",
      env: {  # Version 1.69. Tags do not seem to work correctly with
              # our particular version of puppetlabs-vcsrepo.
              'FACTER_librenms_version':           '0ac05fda69b2a56f775d8c3ae2a41a3c58ef452c',
              'FACTER_librenms_extra_config_file': '/vagrant/vagrant/librenms-extra-config.php',
              'FACTER_servermonitor':              'hostmaster@vagrant.example.lan',
              'FACTER_db_pass':                    'vagrant',
              'FACTER_db_root_pass':               'vagrant',
              'FACTER_admin_pass':                 'vagrant',
              'FACTER_admin_email':                'hostmaster@vagrant.example.lan' }
    box.vm.provision "shell",
      inline: "/opt/puppetlabs/bin/puppet apply /vagrant/vagrant/snmp.pp --modulepath=/vagrant/modules",
      env: {  'FACTER_servermonitor': 'hostmaster@vagrant.example.lan',
              'FACTER_snmp_user':     'librenms',
              # The SNMP password will have to be long enough or you will run
              # into odd issues
              'FACTER_snmp_pass':     'vagrant123' }
    # Work around permission issues reported by validate.php that are very
    # tricky to fix with Puppet which wants to check and maintain state.
    box.vm.provision "shell", path: "vagrant/cleanup.sh"
  end
end
