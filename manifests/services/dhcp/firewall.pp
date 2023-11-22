# This class configures firewall rules for DHCP 
class profile::services::dhcp::firewall {
  ::profile::baseconfig::firewall::service::global { 'DHCP':
    protocol => 'udp',
    port     => [67,68],
  }
}
