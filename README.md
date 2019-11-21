# librenms

A Puppet module for managing LibreNMS

# Usage

Setup LibreNMS, MySQL and php:

    class { '::php':
        config_overrides => { date.timezone => 'Etc/UTC' },
    }
    
    class { '::librenms':
      admin_pass     => 'admin-password',
      db_pass        => 'database-password',
      poller_modules => { 'os'             => 1,
                          'processors'     => 1,
                          'mempools'       => 1,
                          'storage'        => 1,
                          'netstats'       => 1,
                          'hr-mib'         => 1,
                          'ucd-mib'        => 1,
                          'ipSystemStats'  => 1,
                          'ports'          => 1,
                          'ucd-diskio'     => 1,
                          'entity-physical'=> 1,
                        },
    }
    
    class { '::librenms::dbserver':
      bind_address   => '127.0.0.1',
      password       => 'database-password',
      root_password  => 'database-root-password',
    }

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
(still) inaccessible (e.g. being provisioned) are added correctly.

For details see these classes/defines:

* [Class: librenms](manifests/init.pp)
* [Class: librenms::dbserver](manifests/dbserver.pp)
* [Class: librenms::device](manifests/device.pp)

