# Exports a server-definition to be collected by the haproxy backends.
class profile::openstack::nova::haproxy::backend::placement {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "nova-place-${::fqdn}":
    listening_service => 'bk_nova_place_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8778',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
