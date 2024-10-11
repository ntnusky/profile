# This class configures firewall rules for DHCP 
class profile::services::dhcp::firewall {
  ::profile::firewall::infra::all { 'DHCP':
    port               => [67,68],
    transport_protocol => 'udp',
  }
}
