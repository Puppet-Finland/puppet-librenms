class { '::snmpd':
  manage_packetfilter => false,
  puppet_headers      => false,
}

::snmpd::user { $::snmp_user:
  pass => $::snmp_pass,
}

# Add this node to LibreNMS. The realize => true makes the Exec run directly on
# this node instead of getting exported (which does not work with puppet apply)
#
class { '::librenms::device':
  proto   => 'v3',
  user    => $::snmp_user,
  pass    => $::snmp_pass,
  realize => true,
  require => Snmpd::User[$::snmp_user],
}
