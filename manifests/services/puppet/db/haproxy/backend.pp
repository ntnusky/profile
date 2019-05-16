# Configures the haproxy backend for this puppetdb server
class profile::services::puppet::db::haproxy::backend {
  $if = lookup('profile::interfaces::management', String)
  $autoip = $::facts['networking']['interfaces'][$if]['ip']
  $ip = lookup("profile::baseconfig::network::interfaces.${if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $autoip,
  })

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
