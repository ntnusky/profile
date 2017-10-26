# This class configures firewall rules for DNS 
class profile::services::dns::firewall {
  firewall { '400 accept incoming DNS':
    proto  => 'udp',
    dport  => [53],
    action => 'accept',
  }
  firewall { '401 accept incoming DNS':
    proto  => 'tcp',
    dport  => [53],
    action => 'accept',
  }
  require ::profile::baseconfig::firewall 
}
