#!/bin/sh
export PATH=$PATH:/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin

wget https://raw.githubusercontent.com/Puppet-Finland/scripts/master/bootstrap/linux/install-puppet-modules.sh -q -O install-puppet-modules.sh
/bin/sh install-puppet-modules.sh -n librenms
