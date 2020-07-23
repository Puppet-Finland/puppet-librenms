#
# == Class: librenms::params
#
# Defines some variables based on the operating system
class librenms::params {

  include ::os::params

  case $::osfamily {
    'Debian': {
      $clone_source = 'https://github.com/librenms/librenms.git'
      $apache_sites_dir = '/etc/apache2/sites-enabled'
      $dependency_packages = [
        'graphviz',
        'fping',
        'imagemagick',
        'whois',
        'mtr-tiny',
        'nmap',
        'rrdtool',
        'snmp',
        'php-mail',
        'php-net-smtp',
        'python3-dotenv',
        'python3-pip',
        'python3-pymysql'
      ]
      $dependency_pip3_packages = [ 'redis' ]
    }
    default: {
      fail("Unsupported OS: ${::osfamily}")
    }
  }

  $default_poller_modules = {
    'unix-agent'                  => 0,
    'os'                          => 0,
    'ipmi'                        => 0,
    'sensors'                     => 0,
    'processors'                  => 0,
    'mempools'                    => 0,
    'storage'                     => 0,
    'netstats'                    => 0,
    'hr-mib'                      => 0,
    'ucd-mib'                     => 0,
    'ipSystemStats'               => 0,
    'ports'                       => 0,
    'bgp-peers'                   => 0,
    'junose-atm-vp'               => 0,
    'toner'                       => 0,
    'ucd-diskio'                  => 0,
    'wifi'                        => 0,
    'ospf'                        => 0,
    'cisco-ipsec-flow-monitor'    => 0,
    'cisco-remote-access-monitor' => 0,
    'cisco-cef'                   => 0,
    'cisco-sla'                   => 0,
    'cisco-mac-accounting'        => 0,
    'cipsec-tunnels'              => 0,
    'cisco-ace-loadbalancer'      => 0,
    'cisco-ace-serverfarms'       => 0,
    'netscaler-vsvr'              => 0,
    'aruba-controller'            => 0,
    'entity-physical'             => 0,
    'applications'                => 0,
    'cisco-asa-firewall'          => 0,
    'mib'                         => 0
  }
}
