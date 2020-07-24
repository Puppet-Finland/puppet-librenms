notify { 'Provisioning LibreNMS': }

host { $::my_host:
  ensure => 'present',
  ip     => $::my_ip,
  target => '/etc/hosts',
}

package { 'git':
  ensure => 'present',
  before => Class['::librenms::install'],
}

class { '::mysql::server':
  root_password    => $::db_root_pass,
  restart          => true,
  override_options => { 'server' => { 'bind_address' => '127.0.0.1' } },
  before           => Class['::librenms::config'],
}

::mysql::db { 'librenms':
  user     => 'librenms',
  password => $::db_pass,
  host     => 'localhost',
  grant    => ['ALL'],
  charset  => 'utf8',
  collate  => 'utf8_unicode_ci',
  before   => Class['::librenms::config'],
  require  => Class['::mysql::server'],
}

class { '::librenms':
  version        => $::librenms_version,
  manage_php     => true,
  manage_apache  => true,
  ssl            => true,
  admin_pass     => $::admin_pass,
  db_pass        => $::db_pass,
  admin_email    => $::admin_email,
  poller_modules => {
    'os'              => 1,
    'processors'      => 1,
    'mempools'        => 1,
    'storage'         => 1,
    'netstats'        => 1,
    'hr-mib'          => 1,
    'ucd-mib'         => 1,
    'ipSystemStats'   => 1,
    'ports'           => 1,
    'ucd-diskio'      => 1,
    'entity-physical' => 1,
  },
}

file { '/opt/librenms/librenms-extra-config.php':
  ensure  => 'present',
  source  => $::librenms_extra_config_file,
  owner   => 'librenms',
  group   => 'librenms',
  require => Class['::librenms'],
}

class { '::snmpd':
  manage_packetfilter => false,
}

::snmpd::user { $::snmp_user:
  pass => $::snmp_pass,
}

# Add this node to LibreNMS. The realize => true makes the Exec run directly on
# this node instead of getting exported (which does not work with puppet apply)
#
class { '::librenms::device':
  proto   => 'v3',
  user    => $::snmp_user,
  pass    => $::snmp_pass,
  realize => true,
  # Ensure that LibreNMS is fully setup before we try to add this node this it
  require => [ Snmpd::User[$::snmp_user], Class['::librenms'], ],
}

# This is needed when experimenting with LibreNMS service checks
package { 'monitoring-plugins':
  ensure => 'present',
}
