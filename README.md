# librenms

A Puppet module for managing LibreNMS

# Usage

Example usage using Hiera:

    classes:
        - librenms
        - librenms::dbserver
    
    librenms::admin_pass: '<password>'
    librenms::db_pass: '<librenms-database-password>'
    librenms::dbserver::bind_address: '127.0.0.1'
    librenms::dbserver::password: '<librenms-database-password>'
    librenms::dbserver::root_password: '<password>'
    php::config_overrides:
        date.timezone: 'Etc/UTC'


# TODO

- Ensure that all the dependencies defined correctly (run on a fresh host)
- Remove the operating system default virtualhost
- Add https virtualhost support
- Add redirect from webserver root to /librenms
