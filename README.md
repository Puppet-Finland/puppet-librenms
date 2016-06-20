# librenms

A Puppet module for managing LibreNMS

# Usage

Example usage using Hiera:

    classes:
        - librenms
        - librenms::dbserver
    
    librenms::db_pass: '<password>'
    librenms::admin_pass: '<password>'
    librenms::dbserver::bind_address: '127.0.0.1'
    librenms::dbserver::root_password: '<password>'
    php::config_overrides:
        date.timezone: 'Etc/UTC'

