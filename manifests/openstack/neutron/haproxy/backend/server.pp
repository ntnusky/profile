# Configures the haproxy backends for neutron
class profile::openstack::neutron::haproxy::backend::server {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "neutron-public-${::fqdn}":
    listening_service => 'bk_neutron_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9696',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "neutron-admin-${::fqdn}":
    listening_service => 'bk_neutron_api_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9696',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
