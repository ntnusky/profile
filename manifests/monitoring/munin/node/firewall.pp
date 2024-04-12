# This class opens the firewall for the munin-node
class profile::monitoring::munin::node::firewall {
  $v4networks = lookup('profile::networking::infrastructure::ipv4::prefixes', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::V4::CIDR],
  })
  $v6networks = lookup('profile::networking::infrastructure::ipv6::prefixes', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::V6::CIDR],
  })

  require ::profile::baseconfig::firewall

  $v4networks.each | $net | {
    firewall { "050 accept incoming Munin from ${net}":
      proto  => 'tcp',
      dport  => [4949],
      action => 'accept',
      source => $net,
    }
  }

  $v6networks.each | $net | {
    firewall { "050 accept incoming Munin from ${net}":
      proto  => 'tcp',
      dport  => [4949],
      action => 'accept',
      source => $net,
      provider => 'ip6tables',
    }
  }
}
