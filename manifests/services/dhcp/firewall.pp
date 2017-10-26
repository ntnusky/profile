# This class configures firewall rules for DHCP 
class profile::services::dhcp::firewall {
  $management_net = hiera('profile::networks::management')

  firewall { '400 accept incoming DHCP':
    proto  => 'udp',
    sport  => [67,68],
    dport  => [67,68],
    action => 'accept',
  }

  firewall { '400 Accept incoming OMAPI requests':
    proto       => 'tcp',
    dport       => 7911,
    action      => 'accept',
    source      => $management_net,
  }

  require ::profile::baseconfig::firewall 
}
