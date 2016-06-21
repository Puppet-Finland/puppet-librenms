#
# == Class: librenms::config
#
# Configure a virtual host for LibreNMS
#
class librenms::config
(
    String  $system_user,
            $basedir,
    String  $server_name,
    String  $admin_user,
    String  $admin_pass,
    String  $admin_email,
            $db_user,
            $db_host,
            $db_pass

) inherits librenms::params
{

    File {
        ensure => 'present',
        mode   => '0755',
    }

    file { 'librenms-apache-site-conf':
        path    => "${::librenms::params::apache_sites_dir}/librenms.conf",
        content => template('librenms/apache_vhost.conf.erb'),
        owner  => $::os::params::adminuser,
        group  => $::os::params::admingroup,
        require => Class['::apache2::install'],
    }

    file { 'librenms-config.php':
        path    => "${basedir}/config.php",
        owner   => $system_user,
        group   => $system_user,
        content => template('librenms/config.php.erb'),
    }

    php::module { 'mcrypt':
        ensure => 'enabled',
    }

    Exec {
        user    => $::os::params::adminuser,
        path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin', '/usr/local/sbin' ],
    }

    if $db_host == 'localhost' {
        $build_base_php_require = [ File['librenms-config.php'], Class['::librenms::dbserver'] ]
    } else {
        $build_base_php_require = File['librenms-config.php']
    }

    exec { 'librenms-build-base.php':
        command => "php ${basedir}/build-base.php && touch ${basedir}/.build-base.php-ran",
        creates => "${basedir}/.build-base.php-ran",
        require => $build_base_php_require,
    }

    exec { 'librenms-adduser.php':
        command => "php adduser.php ${admin_user} ${admin_pass} 10 ${admin_email} && touch ${basedir}/.adduser.php-ran",
        creates => "${basedir}/.adduser.php-ran",
        require => Exec['librenms-build-base.php'],
    }

}
