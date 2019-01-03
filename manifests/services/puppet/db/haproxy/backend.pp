# Configures the haproxy backend for this puppetdb server 
class profile::services::puppet::db::haproxy::backend {
  $if = hiera('profile::interfaces::management')
  $autoip = $::facts['networking']['interfaces'][$if]['ip']
  $ip = hiera("profile::interfaces::${if}::address", $autoip)

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
