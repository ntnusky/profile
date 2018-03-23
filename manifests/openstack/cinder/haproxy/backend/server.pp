# Configures the haproxy backends for cinder
class profile::openstack::cinder::haproxy::backend::server {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "cinder-public-${::fqdn}":
    listening_service => 'bk_cinder_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8776',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "cinder-admin-${::fqdn}":
    listening_service => 'bk_cinder_api_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8776',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
