host { $::my_host:
  ensure => 'present',
  ip     => $::my_ip,
  target => '/etc/hosts',
}
