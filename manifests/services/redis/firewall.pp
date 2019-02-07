# Configure firewall for redis servers
class profile::services::redis::firewall {
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
    firewall { "050 accept redis-server from ${net}":
      proto  => 'tcp',
      dport  => 6379,
      action => 'accept',
      source => $net,
    }
  }

  $infrav6.each | $net | {
    firewall { "050 accept redis-server from ${net}":
      proto    => 'tcp',
      dport    => 6379,
      action   => 'accept',
      source   => $net,
      provider => 'ip6tables',
    }
  }
}
