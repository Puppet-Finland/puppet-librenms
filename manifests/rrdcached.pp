#
# == Class: librenms::rrdcached
#
# Configure rrdcached specifically for LibreNMS. This only supports
# systemd-based distros at the moment.
#
class librenms::rrdcached inherits librenms::params {

    ensure_resource('package', 'rrdcached', { 'ensure' => 'present' })

    if str2bool($::has_systemd) {
        file { 'librenms-rrdcached-librenms.service':
            ensure  => 'present',
            name    => '/etc/systemd/system/rrdcached-librenms.service',
            content => template('librenms/rrdcached-librenms.service.erb'),
            owner   => $::os::params::adminuser,
            group   => $::os::params::admingroup,
            mode    => '0755',
            require => Package['rrdcached'],
            notify  => Class['systemd::service'],
        }

        service { 'librenms-rrdcached-librenms':
            ensure  => 'running',
            enable  => true,
            name    => 'rrdcached-librenms',
            require => [ Class['systemd::service'], File['librenms-rrdcached-librenms.service'] ],
        }
    }
}
