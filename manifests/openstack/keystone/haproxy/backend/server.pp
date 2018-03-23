# Configures the haproxy backends for keystone
class profile::openstack::keystone::haproxy::backend::server {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "keystone-public-${::fqdn}":
    listening_service => 'bk_keystone_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '5000',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "keystone-admin-${::fqdn}":
    listening_service => 'bk_keystone_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '35357',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "keystone-internal-${::fqdn}":
    listening_service => 'bk_keystone_internal',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '5000',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
