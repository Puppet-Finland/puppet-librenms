#
# == Class: librenms::install
#
# Handles installation of LibreNMS network monitoring tool
#
class librenms::install
(
    $user,
    $clone_source,
    $basedir
)
{
    # Add libreNMS user
    user {'librenms-user':
        ensure     => 'present',
        name       => $user,
        home       => $basedir,
        managehome => false,
        system     => true,
    }
    ->
    vcsrepo { 'librenms-repo-clone':
        ensure   => present,
        path     => $basedir,
        provider => 'git',
        source   => $::librenms::clone_source,
    }
    ->
    file { 'librenms-rrd-dir':
        ensure => directory,
        path   => "${basedir}/rrd",
        mode   => '0775',
        owner  => $user,
        group  => $user,
    }
    ->
    file { 'librenms-logs-dir':
        ensure => directory,
        path   => "${basedir}/logs",
        mode   => '0775',
        owner  => $user,
        group  => $user,
    }

    # move all files to librenms user
    exec { 'librenms-set-ownership':
        path        => ['/bin', '/usr/bin'],
        command     => "chown -R ${user}:${user} ${basedir}",
        refreshonly => true,
        subscribe   => [
                        User['librenms-user'],
                        Vcsrepo['librenms-repo-clone'],
                        File['librenms-rrd-dir'],
                        File['librenms-logs-dir'],
                        ],
    }

    # Hack www-data to librenms group, if www-data user is defined
    User <| title == 'www-data' |> {
        groups  +> [$user, ],
        require +> [User['librenms-user'], ],
    }

    # Dependencies
    include ::php
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

    ensure_packages($::librenms::params::dependency_packages, {'ensure' => 'present'})
}
