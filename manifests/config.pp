#
# == Class: librenms::config
#
# Configure a virtual host for LibreNMS
#
class librenms::config
(
    $basedir,
    $server_name,

) inherits librenms::params
{

    file {'librenms-apache-site-conf':
        ensure  => 'file',
        path    => "${::librenms::params::apache_sites_dir}/librenms.conf",
        content => template('librenms/apache_vhost.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
    }

    php::module { 'mcrypt':
        ensure => 'enabled',
    }
}
