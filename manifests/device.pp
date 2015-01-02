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
#   Snmp protocol version. Valid values are 'v2c' and 'v3' (default). This 
#   parameter is here primarily to reduce the conditional logic in this class.
#
class librenms::device
(
    $librenms_basedir = '/opt/librenms',
    $community='',
    $user='',
    $pass='',
    $proto = 'v3'
)
{
    $basecmd = "${librenms_basedir}/addhost.php ${::fqdn}"

    case $proto {
        'v2c':    { $params = "${community} ${proto}" }
        'v3':     { $params = "ap ${proto} ${user} ${pass} ${pass} sha aes" }
        default: { fail("Invalid value ${proto} for parameter \$proto") }
    }

    $fullcmd = "${basecmd} ${params}"

    # This command will get run on every Puppet run on every node. However, it 
    # should be fairly cheap and the alternative (mysql + grep) is probably not 
    # better and might break in the future.
    @@exec { "Add ${::fqdn} to librenms":
        command => "${fullcmd}",
        path => [ "${librenms_basedir}", "/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin", "usr/local/sbin" ],
        unless => ["mysql --defaults-extra-file=/root/.my.cnf -e \"SELECT hostname FROM librenms.devices WHERE hostname = \'${fqdn}\'\"|grep ${::fqdn}"],
        user => 'root',
        tag => 'librenms-add_device',
    }
}
