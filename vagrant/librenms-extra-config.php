<?php

# Disable automatic updates
$config['update'] = 0;

# Enable service checks
$config['show_services']             = 1;

# Purge old data
$config['syslog_purge']              = 90;
$config['eventlog_purge']            = 90;
$config['authlog_purge']             = 90;
$config['perf_times_purge']          = 90;
$config['device_perf_purge']         = 7;
$config['rrd_purge']                 = 90;
$config['ports_purge']               = true;
