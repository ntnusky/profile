# Configure firewall for uchiwa
class profile::sensu::uchiwa::firewall {
  require ::firewall

  firewall { '040 accept http':
    proto  => 'tcp',
    dport  => 80,
    action => 'accept',
  }
  firewall { '041 accept https':
    proto  => 'tcp',
    dport  => 443,
    action => 'accept',
  }
  firewall { '040 ipv6 accept http':
    proto    => 'tcp',
    dport    => 80,
    action   => 'accept',
    provider => 'ip6tables',
  }
  firewall { '041 ipv6 accept https':
    proto    => 'tcp',
    dport    => 443,
    action   => 'accept',
    provider => 'ip6tables',
  }
}
