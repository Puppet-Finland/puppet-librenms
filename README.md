# librenms

A Puppet module for managing LibreNMS

# Usage

An example on how to use this module with puppetlabs-apache to setup LibreNMS
to listen on HTTP is available in [vagrant/librenms.pp](vagrant/librenms.pp).

To import a node into LibreNMS using exported resources:

    class { '::snmpd':
      iface              => 'eth0',
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
