# This class configures firewall rules for DNS 
class profile::services::dns::firewall {
  require ::profile::baseconfig::firewall 

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
  firewall { '400 ipv6 accept incoming DNS':
    proto    => 'udp',
    dport    => [53],
    action   => 'accept',
    provider => 'ip6tables',
  }
  firewall { '401 ipv6 accept incoming DNS':
    proto    => 'tcp',
    dport    => [53],
    action   => 'accept',
    provider => 'ip6tables',
  }
}
