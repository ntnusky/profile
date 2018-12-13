# This class configures the firewall, to open it for the dev-server
class profile::services::dashboard::dev::firewall {
  $ipv4_management_nets = lookup(
      'profile::networking::management::ipv4::prefixes',
      Array, 'unique', [])
  $ipv6_management_nets = lookup(
      'profile::networking::management::ipv6::prefixes',
      Array, 'unique', [])

  require ::profile::baseconfig::firewall

  $ipv4_management_nets.each |$net| {
    firewall { "700 Accept the dev-server from ${net}":
      proto  => 'tcp',
      dport  => [8080],
      action => 'accept',
      source => $net,
    }
  }
  $ipv6_management_nets.each |$net| {
    firewall { "700 Accept the dev-server from ${net}":
      proto    => 'tcp',
      dport    => [8080],
      action   => 'accept',
      provider => 'ip6tables',
      source   => $net,
    }
  }
}
