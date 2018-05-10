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

For details see these classes/defines:

* [Class: librenms](manifests/init.pp)
* [Class: librenms::dbserver](manifests/dbserver.pp)
* [Class: librenms::device](manifests/device.pp)

