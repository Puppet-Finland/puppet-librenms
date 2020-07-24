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
  $version = 'master',
  String $php_timezone = 'Etc/UTC',
  Boolean $manage_apache = true,
  Boolean $manage_php = true,
  Boolean $ssl = false,
  String $apache_servername = 'librenms.vagrant.example.lan',
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

  if $manage_php {
    package {['php-mysql', 'php-gd', 'php-cli', 'php-pear', 'php-curl',
              'php-snmp', 'php-net-ipv6', 'php-zip', 'php-mbstring',
              'php-json']:
              ensure => 'present',
              before => Class['::librenms::install'],
    }

    # validate.php will complain if PHP timezone is missing
    file { '/etc/php/7.2/cli/conf.d/30-timezone.ini':
      ensure  => 'present',
      content => "date.timezone = ${php_timezone}\n",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['php-cli'],
    }
  }

  class { '::librenms::rrdcached':
    rrdcached_pidfile    => $rrdcached_pidfile,
    rrdcached_socketfile => $rrdcached_socketfile,
  }

  class { '::librenms::install':
    version              => $version,
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

  if $manage_apache {
    class { '::librenms::apache':
      servername => $apache_servername,
      ssl        => $ssl,
    }
  }

  include ::librenms::devices
}
