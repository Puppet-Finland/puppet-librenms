#!/bin/sh
echo I am provisioning...
export FACTER_is_vagrant='true'
wget https://raw.githubusercontent.com/Puppet-Finland/scripts/66badaff297b4ba1ff0d71d589198e17b0f28a06/bootstrap/linux/install-puppet.sh -q -O install-puppet.sh
/bin/sh install-puppet.sh
