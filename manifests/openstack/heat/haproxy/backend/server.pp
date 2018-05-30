# Configures the haproxy backends for heat
class profile::openstack::heat::haproxy::backend::server {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "heat-public-${::fqdn}":
    listening_service => 'bk_heat_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8004',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "heat-admin-${::fqdn}":
    listening_service => 'bk_heat_api_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8004',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "heat-cfn-public-${::fqdn}":
    listening_service => 'bk_heat_cfn_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8000',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "heat-cfn-admin-${::fqdn}":
    listening_service => 'bk_heat_cfn_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8000',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
