#
# == Class: librenms::rrdcached
#
# Configure rrdcached specifically for LibreNMS. This only supports
# systemd-based distros at the moment.
#
class librenms::rrdcached
(
    Stdlib::Absolutepath $rrdcached_pidfile,
    Stdlib::Absolutepath $rrdcached_socketfile,

) inherits librenms::params {

    ensure_resource('package', 'rrdcached', { 'ensure' => 'present' })

    if str2bool($::has_systemd) {

        include ::systemd

        file { 'librenms-etc-default-rrdcached':
            ensure  => 'present',
            name    => '/etc/default/rrdcached',
            content => template('librenms/rrdcached.erb'),
            owner   => $::os::params::adminuser,
            group   => $::os::params::admingroup,
            mode    => '0755',
            require => Package['rrdcached'],
            notify  => Class['systemd::service'],
        }

        service { 'librenms-rrdcached':
            ensure  => 'running',
            enable  => true,
            name    => 'rrdcached',
            require => [ Class['systemd::service'], File['librenms-etc-default-rrdcached'] ],
        }s
    }
}
