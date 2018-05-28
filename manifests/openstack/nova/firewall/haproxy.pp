# Configures the firewall to accept incoming traffic to the nova API. 
class profile::openstack::nova::firewall::haproxy {
  require ::profile::baseconfig::firewall

  firewall { '500 accept IPv4 Nova API':
    proto  => 'tcp',
    dport  => '8774',
    action => 'accept',
  }

  firewall { '500 accept IPv6 Nova API':
    proto    => 'tcp',
    dport    => '8774',
    action   => 'accept',
    provider => 'ip6tables',
  }

  firewall { '500 accept IPv4 Nova Placement API':
    proto  => 'tcp',
    dport  => '8778',
    action => 'accept',
  }

  firewall { '500 accept IPv6 Nova Placement API':
    proto    => 'tcp',
    dport    => '8778',
    action   => 'accept',
    provider => 'ip6tables',
  }

  firewall { '500 accept IPv4 Nova vncproxy':
    proto  => 'tcp',
    dport  => '6080',
    action => 'accept',
  }

  firewall { '500 accept IPv6 Nova vncproxy':
    proto    => 'tcp',
    dport    => '6080',
    action   => 'accept',
    provider => 'ip6tables',
  }
}
