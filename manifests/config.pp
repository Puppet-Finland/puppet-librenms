#
# == Class: librenms::config
#
# Configure a virtual host for LibreNMS
#
class librenms::config {
    $basedir = $::librenms::clone_target
    $server_name = $::librenms::server_name
    $apache_sites_dir = $::librenms::apache_sites_dir

    file {'librenms-apache-site-conf':
        ensure  => 'file',
        path    => "${apache_sites_dir}/librenms.conf",
        content => template('librenms/apache_vhost.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
    }

    # enable php5-crypt module
    exec { "enablemcrypt":
        path    => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        command => "php5enmod mcrypt",
        unless  => "find /etc/php5/apache2 -type l -name '*mcrypt.ini' | grep ini",
        require => Class['librenms::install'],
    }
}
