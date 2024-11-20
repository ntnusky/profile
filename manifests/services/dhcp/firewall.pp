# This class configures firewall rules for DHCP 
class profile::services::dhcp::firewall {
  ::profile::firewall::infra::all { 'DHCP':
    port               => [67,68],
    transport_protocol => 'udp',
  }
  # DHCP-servers need to ssh to each-other to sync acldata
  ::profile::firewall::infra::all { 'dhcp-ssh':
    port => 22,
  }
}
