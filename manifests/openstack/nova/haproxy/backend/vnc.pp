# Exports a server-definition to be collected by the haproxy backends.
class profile::openstack::nova::haproxy::backend::vnc {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "nova-vnc-${::fqdn}":
    listening_service => 'bk_nova_vnc',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '6080',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
