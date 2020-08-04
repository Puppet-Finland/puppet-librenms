#!/bin/sh
echo I am provisioning...
export FACTER_is_vagrant='true'
wget https://raw.githubusercontent.com/Puppet-Finland/scripts/3c1cf163edeebceebd4a29c7c28e6e3a4a11c319/bootstrap/linux/install-puppet.sh -q -O install-puppet.sh
/bin/sh install-puppet.sh
