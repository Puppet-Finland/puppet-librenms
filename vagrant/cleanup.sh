#!/bin/sh
#
# Various cleanup tasks that are next to impossible to do with Puppet. Primarily needed
# to keep validate.php happy.

chown -R librenms:librenms /opt/librenms

setfacl -d -m g::rwx /opt/librenms/bootstrap/cache /opt/librenms/storage /opt/librenms/logs /opt/librenms/rrd

chmod -R ug=rwX /opt/librenms/bootstrap/cache /opt/librenms/storage /opt/librenms/logs /opt/librenms/rrd

echo "y"|sudo -u librenms -H -S /opt/librenms/scripts/github-remove --discard
