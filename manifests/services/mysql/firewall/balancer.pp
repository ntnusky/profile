#Configures the firewall for the mysql loadbalancers
class profile::services::mysql::firewall::balancer {
  require ::profile::baseconfig::firewall

  $infrav4 = lookup('profile::networking::infrastructure::ipv4::prefixes', {
    'value_type' => Array[Stdlib::IP::Address::V4::CIDR],
    'merge'      => 'unique',
  })
  $infrav6 = lookup('profile::networking::infrastructure::ipv6::prefixes', {
    'value_type'    => Array[Stdlib::IP::Address::V6::CIDR],
    'merge'         => 'unique',
    'default_value' => [],
  })

  $infrav4.each | $net | {
    firewall { "071 Accept incoming MySQL requests from ${net}":
      source => $net,
      proto  => 'tcp',
      dport  => 3306,
      action => 'accept',
    }
  }

  $infrav6.each | $net | {
    firewall { "071 Accept incoming MySQL requests from ${net}":
      source   => $net,
      proto    => 'tcp',
      dport    => 3306,
      action   => 'accept',
      provider => 'ip6tables',
    }
  }
}
