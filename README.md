# librenms

A Puppet module for managing LibreNMS

# Usage

The Puppet manifest used by Vagrant
([vagrant/librenms.pp](vagrant/librenms.pp)) shows how to

* Setup LibreNMS (install, configuration, permissions, ACLs, users, etc.)
* Use puppetlabs-mysql to configure database, user and grants
* Setup snmpd and create and SNMPv3 user
* Add the LibreNMS node to LibreNMS

The manifest used by Vagrant uses two optional features of this module that

* Install the required php packages
* Configure Apache to serve LibreNMS on port 80 (http)

## Hints for production

To import a node into LibreNMS using exported resources:

    class { '::snmpd':
      allow_address_ipv4 => '10.0.0.0',
      allow_netmask_ipv4 => '8',
      users              => { 'monitor' => { 'pass' => 'my-password' } },
    }
    
    class { '::librenms::device':
      proto => 'v3',
      user  => 'monitor',
      pass  => 'my_password',
    }

To use SNMPv2 instead:

    class { '::librenms::device':
      proto      => 'v2',
      community  => 'public',
    }

Create and remove devices using [LibreNMS v0 API](https://docs.librenms.org/API/Devices/):

    librenms_device { 'snmpv3.example.org':
      ensure     => 'present',
      url        => 'https://librenms.example.org/api/v0',
      auth_token => '0123456789abcde0123456789abcded0',
      snmpver    => 'v3',
      authlevel  => 'noAuthNoPriv',
      authname   => 'snmpuser',
      authpass   => 'secret',
      authalgo   => 'sha',
      cryptopass => 'secret',
      cryptoalgo => 'aes',
    }
    
    librenms_device { 'snmpv2.example.org':
      ensure     => 'present',
      url        => 'https://librenms.example.org/api/v0',
      auth_token => '0123456789abcde0123456789abcded0',
      snmpver    => 'v2c',
      community  => 'public',
    }
    
    # Ensure that a decommissioned node is not present in LibreNMS
    librenms_device { 'decommissioned.example.org':
      ensure => 'absent',
    }

The provider uses the "force_add" parameter to ensure that nodes that are
(temporarily) inaccessible (e.g. being provisioned) are added correctly.

You can also manage services using the [LibreNMS v0 API](https://docs.librenms.org/API/Services/):

    librenms_service { 'http-on-librenms':
      ensure     => 'present',
      url        => 'http://librenms.example.org/api/v0',
      auth_token => '0123456789abcde0123456789abcded0',
      hostname   => 'librenms.example.org',
      type       => 'http',
      ip         => 'librenms.example.org',
      param      => 'C 50 --sni -S',
    }

There are couple of caveats regarding service management:

* The "desc" parameter, which defaults to the resource title, is used as an identifier at the LibreNMS. This is because it is the only property which is purely informational. You can use this to import existing resources to Puppet. If multiple services matching the same "desc" on the same device are found then Puppet will bail out and ask you to resolve the situation.
* No verification is done on any of the parameters at Puppet or LibreNMS end except for basic data type validation. For example you can change "type" from "http" (valid) to "https" (invalid) without any errors or warnings.

To create CustomOID checks use the librenms_customoid type. Below an example of
how to use this with
[net-snmp-systemd-service-status](https://github.com/Puppet-Finland/net-snmp-systemd-service-status):

    $service = 'sshd'
    
    # Convert human-readable (ASCII) name to an OID
    $oid = librenms::name_to_oid($service)
    $descr = "${service} on ${::fqdn}"
    
    @@librenms_customoid { $descr:
      ensure    => present,
      
      # Database username and password: there's no API support for manipulating
      # CustomOIDs
      username  => 'librenms',
      password  => 'secret',
      
      # Bind this CustomOID to hostname that matches value of $::fqdn fact
      hostname  => $::fqdn,
      
      # Alternatively use sysName instead for the mapping
      # sysName   => $::hostname,
      
      # Send alerts. We get 0 if service is up, 1 if is down.
      alert     => 1,
      descr     => $descr,
      oid       => $oid,
      # Alert if service is not up (returns 1)
      limit     => 1,
      tag       => 'default'
    }

Then just realize the exported resources on the LibreNMS server:

    Librenms_customoid <<| tag == 'default' |>>

See
[lib/puppet/type/librenms_customoid.rb](lib/puppet/type/librenms_customoid.rb)
for details.

# Testing with Vagrant

If you have Vagrant and virtualbox installed then setting up LibreNMS test
instance from scratch should be as easy as:

    $ vagrant up

LibreNMS UI can be reached via

* https://192.168.152.10 (librenms)
* https://192.168.152.11 (librenms-focal)

Username is "admin" and password is "vagrant". The instance adds itself to
LibreNMS, so you should see one device, "librenms.vagrant.example.lan" under
devices.

If you want to use snmpwalk note that the username is "librenms" and password
is "vagrant123".
