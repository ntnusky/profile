# This class configures firewall rules for DHCP 
class profile::services::dhcp::firewall {
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

  firewall { '400 accept incoming DHCP':
    proto  => 'udp',
    sport  => [67,68],
    dport  => [67,68],
    action => 'accept',
  }

  $infrav4.each | $net | {
    firewall { "400 Accept incoming OMAPI requests from ${net}":
      proto  => 'tcp',
      dport  => 7911,
      action => 'accept',
      source => $net,
    }
  }
  $infrav6.each | $net | {
    firewall { "400 Accept incoming OMAPI requests from ${net}":
      proto    => 'tcp',
      dport    => 7911,
      action   => 'accept',
      source   => $net,
      provider => 'ip6tables',
    }
  }
}
