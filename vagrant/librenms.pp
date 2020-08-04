notify { 'Provisioning LibreNMS': }

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
  version           => $::librenms_version,
  manage_php        => true,
  manage_apache     => true,
  ssl               => true,
  admin_pass        => $::admin_pass,
  db_pass           => $::db_pass,
  admin_email       => $::admin_email,
  poller_modules    => {
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
  extra_config_file => '/opt/librenms/librenms-extra-config.php',
}

file { '/opt/librenms/librenms-extra-config.php':
  ensure  => 'present',
  source  => $::librenms_extra_config_file,
  owner   => 'librenms',
  group   => 'librenms',
  require => Class['::librenms'],
}

# This is needed when experimenting with LibreNMS service checks
package { 'monitoring-plugins':
  ensure => 'present',
}
