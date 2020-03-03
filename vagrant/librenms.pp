notify { 'Provisioning LibreNMS': }

$servermonitor = 'hostmaster@vagrant.example.lan'

host { 'librenms.vagrant.example.lan':
  ensure => 'present',
  ip     => '192.168.152.10',
  target => '/etc/hosts',
}

class { '::librenms':
  admin_pass          => 'vagrant',
  db_pass             => 'vagrant',
  admin_email         => 'hostmaster@vagrant.example.lan',
  manage_apache       => false,
  poller_modules      => {
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
  php_config_overrides => { 'date.timezone'   => 'Etc/UTC' },
}

class { '::librenms::dbserver':
  password             => 'vagrant',
  root_password        => 'vagrant',
  bind_address         => '127.0.0.1',
  allow_addresses_ipv4 => [ '127.0.0.1' ],
}


class { '::apache':
  purge_configs => true,
  default_vhost => false,
  mpm_module    => 'prefork',
}

include ::apache::mod::php
include ::apache::mod::headers
include ::apache::mod::rewrite

apache::vhost { 'librenms':
  servername  => 'librenms.vagrant.example.lan',
  port        => '80',
  docroot     => '/var/www/html',
  proxy_pass  =>
  [
    {
      'path' => '/opt/librenms/html/',
      'url'  => '!',
    }
  ],
  directories =>
    [
      {
        'path'           => '/opt/librenms/html/',
        'options'        => [ 'Indexes', 'FollowSymLinks', 'MultiViews' ],
        'allow_override' => 'All'
      }
    ],
  request_headers =>  [ 'set X-Forwarded-Proto "http"', 'set X-Forwarded-Port "80"' ],
  headers         => [ 'always set Strict-Transport-Security "max-age=15768000; includeSubDomains; preload"' ],
}

