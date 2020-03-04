#
# == Class: librenms::device
#
# This class is used to export an Exec resource that adds this node to librenms.
#
# Note that this class makes quite a few assumptions regarding snmpv3 to 
# simplify the code:
#
# 1. Both authentication and encryption are used with snmpv3
# 2. SHA is used for authentication
# 3. AES is used for encryption
# 4. Both authentication and encryption are required
# 5. The snmp daemon is listening on the default port
#
# == Parameters
#
# [*manage*]
#   Whether to add this node to LibreNMS. Valid values are true (default) and 
#   false. You probably want to set this to false if you're including this class 
#   on test nodes.
# [*librenms_basedir*]
#   The directory into which LibreNMS is installed on the server side. Defaults 
#   to '/opt/librenms'.
# [*community*]
#   The community string to use with SNMPv2(c). Leave empty (default) to 
#   disable snmpv2.
# [*user*]
#   Snmpv3 username. Leave empty (default) to not use snmpv3.
# [*pass*]
#   Snmpv3 user password. Leave empty (default) to not use snmpv3.
# [*proto*]
#   Snmp protocol version. Valid values are 'v1', 'v2c' and 'v3' (default). This 
#   parameter is here primarily to reduce the conditional logic in this class.
# [*realize*]
#   Do not export the Exec that joins this node to LibreNMS. Instead run it
#   directly.  Useful primarily in Vagrant and will only work on the LibreNMS
#   server itself. Defaults to false.
#
class librenms::device
(
    Boolean               $manage = true,
    String                $librenms_basedir = '/opt/librenms',
    Optional[String]      $community = undef,
    Optional[String]      $user = undef,
    Optional[String]      $pass = undef,
    Enum['v1','v2c','v3'] $proto = 'v3',
    Boolean               $realize = false
)
{

    if $manage {

    $basecmd = "${librenms_basedir}/addhost.php ${::fqdn}"

    case $proto {
        'v2c':    { $params = "${community} ${proto}" }
        'v3':     { $params = "ap ${proto} ${user} ${pass} ${pass} sha aes" }
        default: { fail("Invalid value ${proto} for parameter \$proto") }
    }

    $fullcmd = "${basecmd} ${params}"
        $exec_defaults = {  'command' => $fullcmd,
                            'path'    => [ $librenms_basedir, '/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin', 'usr/local/sbin' ],
                            'unless'  => ["mysql --defaults-extra-file=/root/.my.cnf -e \"SELECT hostname FROM librenms.devices WHERE hostname = \'${::fqdn}\'\"|grep ${::fqdn}"], # lint:ignore:140chars
                            'user'    => 'root', }

    # Add the node if it does not already exist in LibreNMS database. The grep 
    # is needed to produce a meaningful return value (0 or 1).
    if $realize {
        exec { "Add ${::fqdn} to librenms":
            * => $exec_defaults,
        }
    } else {
        @@exec { "Add ${::fqdn} to librenms":
            tag => 'librenms-add_device',
            *   => $exec_defaults,
        }
    }
    }
}
