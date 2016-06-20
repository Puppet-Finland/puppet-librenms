#
# == Class: librenms::dbserver
#
# MySQL configurations required by LibreNMS
#
class librenms::dbserver
(
    String $bind_address,
    String $root_password,
    String $host = 'localhost',
    String $user = 'librenms',
    String $password,

) inherits librenms::params
{

    class { '::mysql':
        bind_address      => $bind_address,
        use_root_defaults => true,
        sql_mode          => '',
        root_password     => $root_password,
    }

    class { '::mysql::config::innodb':
        innodb_file_per_table => true,
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
