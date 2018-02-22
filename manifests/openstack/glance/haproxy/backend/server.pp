# Configures the haproxy backends for glance
class profile::openstack::glance::haproxy::backend::server {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "glance-public-${::fqdn}":
    listening_service => 'bk_glance_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9292',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "glance-admin-${::fqdn}":
    listening_service => 'bk_glance_api_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9292',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "glance-registry-${::fqdn}":
    listening_service => 'bk_glance_registry',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9191',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
