# Configures the haproxy backend for this puppetdb server 
class profile::services::puppetdb::haproxy::backend {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "Puppetdb-${::fqdn}":
    listening_service => 'puppetdb',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8081',
    options           => 'check',
  }
}
