#
# == Class: librenms
#
# A Puppet module for managing librenms:
#
# <http://www.librenms.org>
#
class librenms
(
    $user = 'librenms',
    $server_name = $::fqdn,
    $clone_source = $::librenms::params::clone_source,
    $clone_target = '/opt/librenms'

) inherits librenms::params
{
    class { '::librenms::install':
        user         => $user,
        clone_source => $clone_source,
        basedir      => $clone_target,
    }

    class { '::librenms::config':
        basedir     => $clone_target,
        server_name => $server_name,
    }
}
