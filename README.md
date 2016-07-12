# librenms

A Puppet module for managing LibreNMS

# Usage

Example usage using Hiera:

    classes:
        - librenms
        - librenms::dbserver
        - php
    
    librenms::admin_pass: '<password>'
    librenms::db_pass: '<librenms-database-password>'
    librenms::dbserver::bind_address: '127.0.0.1'
    librenms::dbserver::password: '<librenms-database-password>'
    librenms::dbserver::root_password: '<password>'
    
    # Activate poller modules (all disabled by default)
    librenms::poller_modules:
        'os': 1
        'processors': 1
        'mempools': 1
        'storage': 1
        'netstats': 1
        'hr-mib': 1
        'ucd-mib': 1
        'ipSystemStats': 1
        'ports': 1
        'ucd-diskio': 1
        'entity-physical': 1
    
    php::config_overrides:
        date.timezone: 'Etc/UTC'

To export a node into LibreNMS:

    classes:
        - librenms::device
        - snmpd
    
    librenms::device::proto: 'v3'
    librenms::device::user: 'monitor'
    librenms::device::pass: 'my_password'
    
    snmpd::iface: 'eth0'
    snmpd::allow_address_ipv4: '10.0.0.0'
    snmpd::allow_netmask_ipv4: '8'
    snmpd::users:
        monitor:
            pass: 'my_password'

For details see these classes/defines:

* [Class: librenms](manifests/init.pp)
* [Class: librenms::dbserver](manifests/dbserver.pp)
* [Class: librenms::device](manifests/device.pp)

# Dependencies

This module's requirements are listed in [metadata.json](metadata.json). We 
suggest using [puppetfinland/snmpd](https://github.com/Puppet-Finland/snmpd) for 
setting up snmpd on LibreNMS-managed nodes.

# Operating system support

This module has been tested on

* Ubuntu 16.04

Support for most Linux operating systems should be fairly easy to add.

For details see [params.pp](manifests/params.pp).

# TODO

- Add https virtualhost support
