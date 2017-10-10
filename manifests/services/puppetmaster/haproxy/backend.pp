# Configures the haproxy backend for this puppetmaster 
class profile::services::puppetmaster::haproxy::backend {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "Puppet-${::fqdn}":
    listening_service => 'puppetserver',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8140',
    options           => 'check',
  }
}
