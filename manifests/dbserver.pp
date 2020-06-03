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

  class { '::pf_mysql':
    bind_address         => $bind_address,
    allow_addresses_ipv4 => $allow_addresses_ipv4,
    sql_mode             => '',
    root_password        => $root_password,
  }

  class { '::pf_mysql::config::innodb':
    file_per_table => true,
  }

  pf_mysql::database { 'librenms':
    use_root_defaults => true,
  }

  pf_mysql::grant { 'librenms':
    user       => $user,
    host       => $host,
    password   => $password,
    database   => 'librenms',
    privileges => 'ALL',
    require    => Pf_mysql::Database['librenms'],
  }
}
