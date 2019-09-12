#
# == Class: librenms::install
#
# Handles installation of LibreNMS network monitoring tool
#
class librenms::install
(
    String $user,
    String $clone_source,
    String $basedir,
    Hash   $php_config_overrides
)
{
    # Add libreNMS user
    user {'librenms-user':
        ensure     => 'present',
        name       => $user,
        home       => $basedir,
        managehome => false,
        system     => true,
        notify     => Exec['librenms-set-ownership'],
    }

    -> vcsrepo { 'librenms-repo-clone':
        ensure   => present,
        path     => $basedir,
        provider => 'git',
        source   => $::librenms::clone_source,
        notify   => Exec['librenms-set-ownership'],
    }

    -> file { 'librenms-rrd-dir':
        ensure => directory,
        path   => "${basedir}/rrd",
        mode   => '0775',
        owner  => $user,
        group  => $user,
        notify => Exec['librenms-set-ownership'],
    }

    -> file { 'librenms-logs-dir':
        ensure => directory,
        path   => "${basedir}/logs",
        mode   => '0775',
        owner  => $user,
        group  => $user,
        notify => Exec['librenms-set-ownership'],
    }

    # move all files to librenms user
    exec { 'librenms-set-ownership':
        path    => ['/bin', '/usr/bin'],
        command => "chown -R ${user}:${user} ${basedir}",
        onlyif  => "find ${basedir} ! -user ${user}|grep \"${basedir}\"",
        require => User['librenms-user'],
    }

    # Hack www-data to librenms group, if www-data user is defined
    User <| title == 'www-data' |> {
        groups  +> [$user, ],
        require +> [User['librenms-user'], ],
    }

    # Dependencies
    class { '::php':
        config_overrides => $php_config_overrides,
    }
    include ::php::gd
    include ::php::mysql
    include ::php::cli
    include ::php::pear
    include ::php::curl
    include ::php::snmp
    include ::php::mcrypt
    include ::php::json
    include ::php::net_ipv4
    include ::php::net_ipv6
    include ::php::mbstring

    ensure_packages($::librenms::params::dependency_packages, {'ensure' => 'present'})
}
