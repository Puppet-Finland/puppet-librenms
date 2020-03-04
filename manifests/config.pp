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
            $db_pass,
    Hash[String, Integer[0,1]] $poller_modules,
    Integer $poller_threads,
    String  $rrdtool_version,
    Optional[Array[String]] $extra_config_files = undef,

) inherits librenms::params {
    File {
        ensure => 'present',
        mode   => '0755',
    }

    # Construct the poller module hash, with defaults coming from params.pp
    $l_poller_modules = merge($::librenms::params::default_poller_modules, $poller_modules)

    # The LibreNMS-specific rrdcached service will only work on systemd distros 
    # at the moment.
    if str2bool($::has_systemd) {
        $rrdcached_line = "\$config['rrdcached'] = \"unix:/run/rrdcached.sock\";"
    } else {
        $rrdcached_line = '# rrdcached disabled by Puppet because this is not a systemd distro'
    }

    file { 'librenms-config.php':
        path    => "${basedir}/config.php",
        owner   => $system_user,
        group   => $system_user,
        content => template('librenms/config.php.erb'),
        require => Class['::librenms::install'],
    }


    php::module { 'mcrypt':
        ensure  => 'enabled',
        require => Class['::librenms::install'],
    }

    Exec {
        user => $::os::params::adminuser,
        path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin', '/usr/local/sbin' ],
    }

    if $db_host == 'localhost' {
        $build_base_php_require = [ File['librenms-config.php'], Class['::librenms::dbserver'] ]
    } else {
        $build_base_php_require = File['librenms-config.php']
    }

    exec { 'librenms-composer_wrapper.php':
        command => "php ${basedir}/scripts/composer_wrapper.php install --no-dev && touch ${basedir}/.composer_wrapper.php-ran",
        creates => "${basedir}/.composer_wrapper.php-ran",
        require => $build_base_php_require,
    }

    exec { 'librenms-build-base.php':
        command => "php ${basedir}/build-base.php && touch ${basedir}/.build-base.php-ran",
        creates => "${basedir}/.build-base.php-ran",
        require =>
        [
          $build_base_php_require,
          Exec['librenms-composer_wrapper.php'],
        ]
    }

    exec { 'librenms-adduser.php':
        command => "php ${basedir}/adduser.php ${admin_user} ${admin_pass} 10 ${admin_email} && touch ${basedir}/.adduser.php-ran",
        creates => "${basedir}/.adduser.php-ran",
        require => Exec['librenms-build-base.php'],
    }

    file { '/etc/cron.d/librenms':
      ensure  => 'present',
      source  => 'file:///opt/librenms/librenms.nonroot.cron',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Class['::librenms::install'],
    }
}
