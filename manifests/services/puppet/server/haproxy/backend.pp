# Configures the haproxy backend for this puppetmaster 
class profile::services::puppet::server::haproxy::backend {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "Puppetserver-${::fqdn}":
    servername  => $::hostname,
    backendname => 'bk_puppetserver',
  }

  @@haproxy::balancermember { "Puppet-${::fqdn}":
    listening_service => 'bk_puppetserver',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8140',
    options           => 'check',
  }
}
