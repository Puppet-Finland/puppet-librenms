#
# == Class: librenms
#
# A Puppet module for managing librenms:
#
# <http://www.librenms.org>
#
# Currently this is a dummy class. The actual hard lifting is done in 
# librenms::server and librenms::device.
#
class librenms(
    $user = 'librenms',
    $server_name = 'librenms.local',
    $clone_source = 'https://github.com/librenms/librenms.git',
    $clone_target = '/opt/librenms',
    $apache_sites_dir = '/etc/apache2/sites-enabled',
)
{
    include librenms::install
    include librenms::config
    include librenms::server
}
