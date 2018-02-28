# Configures a haproxy server for horizon.
class profile::openstack::horizon::haproxy::backend {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "horizon-${::fqdn}":
    listening_service => 'bk_horizon',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '80',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
