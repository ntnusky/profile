# This class configures firewall rules for DHCP 
class profile::services::dhcp::firewall {
  firewall { '400 accept incoming DHCP':
    proto  => 'udp',
    sport  => [67,68],
    dport  => [67,68],
    action => 'accept',
  }
  require ::profile::baseconfig::firewall 
}
