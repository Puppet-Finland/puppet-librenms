#
# == Class: librenms
#
# A Puppet module for managing librenms:
#
# <http://www.librenms.org>
#
class librenms
(
  $admin_pass,
  $db_pass,
  $user = 'librenms',
  $server_name = $::fqdn,
  $clone_source = $::librenms::params::clone_source,
  $clone_target = '/opt/librenms',
  $admin_user = 'admin',
  $admin_email = $::servermonitor,
  $db_user = 'librenms',
  $db_host = 'localhost',
  $poller_modules = {},
  $poller_threads = 16,
  $php_config_overrides = {},
  $rrdcached_pidfile = '/run/rrdcached.pid',
  $rrdcached_socketfile = '/run/rrdcached.sock',
  $rrdtool_version = '1.7.0',
  $extra_config_file = undef,

) inherits librenms::params
{

  class { '::librenms::rrdcached':
    rrdcached_pidfile    => $rrdcached_pidfile,
    rrdcached_socketfile => $rrdcached_socketfile,
  }

  class { '::librenms::install':
    user                 => $user,
    clone_source         => $clone_source,
    basedir              => $clone_target,
    php_config_overrides => $php_config_overrides,
  }

  class { '::librenms::config':
    system_user       => $user,
    basedir           => $clone_target,
    server_name       => $server_name,
    admin_user        => $admin_user,
    admin_pass        => $admin_pass,
    admin_email       => $admin_email,
    db_user           => $db_user,
    db_host           => $db_host,
    db_pass           => $db_pass,
    poller_modules    => $poller_modules,
    poller_threads    => $poller_threads,
    rrdtool_version   => $rrdtool_version,
    extra_config_file => $extra_config_file,
  }

  include ::librenms::devices
}
