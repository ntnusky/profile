# This class opens the firewall for the munin-node
class profile::monitoring::munin::node::firewall {
  $management_netv4 = hiera('profile::networks::management::ipv4::prefix')
  $management_netv6 = hiera('profile::networks::management::ipv6::prefix')

  require ::profile::baseconfig::firewall 

  firewall { '050 accept incoming Munin':
    proto  => 'tcp',
    dport  => [4949],
    action => 'accept',
    source => $management_netv4,
  }
  firewall { '050 v6accept incoming Munin':
    proto    => 'tcp',
    dport    => [4949],
    action   => 'accept',
    provider => 'ip6tables',
    source   => $management_netv6,
  }
}
