# Exports a server-definition to be collected by the haproxy backends.
class profile::openstack::nova::haproxy::backend::api {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "nova-public-${::fqdn}":
    listening_service => 'bk_nova_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8774',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "nova-admin-${::fqdn}":
    listening_service => 'bk_nova_api_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8774',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
