notify { 'Provisioning LibreNMS': }

$servermonitor = 'hostmaster@vagrant.example.lan'
$snmp_user = 'librenms'
# The SNMP password will have to be long enough or you will run into odd issues
$snmp_pass = 'vagrant123'

host { 'librenms.vagrant.example.lan':
  ensure => 'present',
  ip     => '192.168.152.10',
  target => '/etc/hosts',
}

package { 'git':
  ensure => 'present',
  before => Class['::librenms::install'],
}

class { '::mysql::server':
  root_password    => 'vagrant',
  restart          => true,
  override_options => { 'server' => { 'bind_address' => '127.0.0.1' } },
  before           => Class['::librenms::config'],
}

::mysql::db { 'librenms':
  user     => 'librenms',
  password => 'vagrant',
  host     => 'localhost',
  grant    => ['ALL'],
  before   => Class['::librenms::config'],
  require  => Class['::mysql::server'],
}

class { '::librenms':
  manage_php     => true,
  manage_apache  => true,
  admin_pass     => 'vagrant',
  db_pass        => 'vagrant',
  admin_email    => 'hostmaster@vagrant.example.lan',
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

class { '::snmpd':
  manage_packetfilter => false,
}

::snmpd::user { $snmp_user:
  pass => $snmp_pass,
}

# Add this node to LibreNMS. The realize => true makes the Exec run directly on
# this node instead of getting exported (which does not work with puppet apply)
#
class { '::librenms::device':
  proto   => 'v3',
  user    => $snmp_user,
  pass    => $snmp_pass,
  realize => true,
  # Ensure that LibreNMS is fully setup before we try to add this node this it
  require => [ Snmpd::User[$snmp_user], Class['::librenms'], ],
}

# This is needed when experimenting with LibreNMS service checks
package { 'monitoring-plugins':
  ensure => 'present',
}
