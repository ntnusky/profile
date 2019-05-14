# Configures the haproxy backend for this puppetmaster 
class profile::services::puppet::server::haproxy::backend {
  $if = lookup('profile::interfaces::management', String)
  $autoip = $::facts['networking']['interfaces'][$if]['ip']
  $ip = lookup("profile::baseconfig::network::interfaces.${if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $autoip
    })

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
