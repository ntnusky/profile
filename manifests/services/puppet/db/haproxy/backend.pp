# Configures the haproxy backend for this puppetdb server 
class profile::services::puppet::db::haproxy::backend {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "PuppetDB-${::fqdn}":
    servername  => $::hostname,
    backendname => 'bk_puppetdb',
  }

  @@haproxy::balancermember { "Puppetdb-${::fqdn}":
    listening_service => 'bk_puppetdb',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8081',
    options           => 'check',
  }
}
