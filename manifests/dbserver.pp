#
# == Class: librenms::dbserver
#
# MySQL configurations required by LibreNMS
#
class librenms::dbserver
(
  String  $bind_address,
  String  $root_password,
  String  $password,
          $allow_addresses_ipv4,
  String  $host = 'localhost',
  String  $user = 'librenms',

) inherits librenms::params
{

  class { '::mysql':
    bind_address         => $bind_address,
    allow_addresses_ipv4 => $allow_addresses_ipv4,
    sql_mode             => '',
    root_password        => $root_password,
  }

  class { '::mysql::config::innodb':
    file_per_table => true,
  }

  mysql::database { 'librenms':
    use_root_defaults => true,
  }

  mysql::grant { 'librenms':
    user       => $user,
    host       => $host,
    password   => $password,
    database   => 'librenms',
    privileges => 'ALL',
    require    => Mysql::Database['librenms'],
  }
}
