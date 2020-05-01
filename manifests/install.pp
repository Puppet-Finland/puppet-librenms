#
# == Class: librenms::install
#
# Handles installation of LibreNMS network monitoring tool
#
class librenms::install
(
  Boolean $manage_php,
  String  $user,
  String  $clone_source,
  String  $basedir,
  Hash    $php_config_overrides
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

  vcsrepo { 'librenms-repo-clone':
    ensure   => present,
    path     => $basedir,
    provider => 'git',
    source   => $::librenms::clone_source,
    # Without this the rrd unit file would create /opt/librenms/rrd
    # directory and make this resource fail
    before   => Class['::librenms::rrdcached'],
    require  => User['librenms-user'],
  }

  # Set permissions and ACLs as described in
  #
  # <https://docs.librenms.org/Installation/Installation-Ubuntu-1804-Apache/>
  #
  file { $basedir:
    ensure  => 'directory',
    owner   => $user,
    group   => $user,
    mode    => '0750',
    recurse => true,
    require => Vcsrepo['librenms-repo-clone'],
  }

  package { 'acl':
    ensure => 'present',
  }

  # Set ACLs for the files that need to be editable for all
  $acl_dirs = ["${basedir}/rrd", "${basedir}/logs", "${basedir}/bootstrap/cache", "${basedir}/storage"].each |$dir| {
    posix_acl { $dir:
      action     => set,
      provider   => posixacl,
      permission => [ 'default:g::rwx', 'g::rwx'],
      recursive  => true,
      require    => [File[$basedir], Package['acl']],
    }
  }

  # Hack www-data to librenms group, if www-data user is defined
  User <| title == 'www-data' |> {
    groups  +> [$user, ],
    require +> [User['librenms-user'], ],
  }

  if $manage_php {
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
    include ::php::zip
  }

  ensure_packages($::librenms::params::dependency_packages, {'ensure' => 'present'})
}
