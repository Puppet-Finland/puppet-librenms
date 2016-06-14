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
            $dependency_packages = ['graphviz',
                                    'fping',
                                    'imagemagick',
                                    'whois',
                                    'mtr-tiny',
                                    'nmap',
                                    'python-mysqldb',
                                    'rrdtool']
        }
        default: {
            fail("Unsupported OS: ${::osfamily}")
        }
    }
}
