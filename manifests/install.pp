#
# == Class: librenms::install
#
# Handles installation of LibreNMS network monitoring tool
#
class librenms::install {
    $basedir = $::librenms::clone_target
    $user = $::librenms::user

    # Add libreNMS user
    user {'librenms-user':
        ensure     => 'present',
        name       => $user,
        home       => $basedir,
        managehome => false,
        system     => true,
    }
    -> vcsrepo {'librenms-repo-clone':
        ensure   => present,
        path     => $basedir,
        provider => 'git',
        source   => $::librenms::clone_source,
    }
    -> file {"librenms-rrd-dir":
        ensure => directory,
        path   => "${basedir}/rrd",
        mode   => "0775",
        owner  => $user,
        group  => $user,
    }
    -> file {"librenms-logs-dir":
        ensure => directory,
        path   => "${basedir}/logs",
        mode   => "0775",
        owner  => $user,
        group  => $user,
    }

    # move all files to librenms user
    exec {'librenms-set-ownership':
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

    $apt_requirements = ['php5-cli',
                         'php5-mysql',
                         'php5-gd',
                         'php5-snmp',
                         'php-pear',
                         'php5-curl',
                         'snmp',
                         'graphviz',
                         'php5-mcrypt',
                         'php5-json',
                         'fping',
                         'imagemagick',
                         'whois',
                         'mtr-tiny',
                         'nmap',
                         'python-mysqldb',
                         'php-net-ipv4',
                         'php-net-ipv6',
                         'rrdtool']

    ensure_packages($apt_requirements, {'ensure' => 'present'})
}
