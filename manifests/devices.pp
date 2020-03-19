#
# == Class: librenms::devices
#
# This class is included on the librenms server. Currently it's only purpose is 
# to automatically add all Puppet-managed nodes to the librenms database.
#
class librenms::devices {

  # Add all Puppet-managed nodes ("devices") to librenms
  Exec <<| tag == 'librenms-add_device' |>> {
    require +> [ Class['librenms::config'], ],
  }
}
