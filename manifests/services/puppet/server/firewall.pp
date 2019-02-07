# Configures the firewall for puppetmasters. 
class profile::services::puppet::server::firewall {
  require ::firewall

  $infrav4 = lookup('profile::networking::infrastructure::ipv4::prefixes', {
    'value_type' => Array[Stdlib::IP::Address::V4::CIDR],
    'merge'      => 'unique',
  })
  $infrav6 = lookup('profile::networking::infrastructure::ipv6::prefixes', {
    'value_type' => Array[Stdlib::IP::Address::V6::CIDR],
    'merge'      => 'unique',
  })

  $infrav4.each | $net | {
    firewall { "050 Accept incoming puppet from ${net}":
      proto  => 'tcp',
      dport  => 8140,
      action => 'accept',
      source => $net,
    }
  }
  $infrav6.each | $net | {
    firewall { "050 Accept incoming puppet from ${net}":
      proto    => 'tcp',
      dport    => 8140,
      action   => 'accept',
      source   => $net,
      provider => 'ip6tables',
    }
  }
}
