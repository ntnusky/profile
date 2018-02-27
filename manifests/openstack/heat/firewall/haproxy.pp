# Configures the firewall to accept incoming traffic to the heat API. 
class profile::openstack::heat::firewall::haproxy {
  require ::profile::baseconfig::firewall

  firewall { '500 accept heat API':
    proto       => 'tcp',
    dport       => '8004',
    action      => 'accept',
  }

  firewall { '500 accept heat cloudformation API':
    proto       => 'tcp',
    dport       => '8000',
    action      => 'accept',
  }

  firewall { '500 v6 accept heat API':
    proto    => 'tcp',
    dport    => '8004',
    action   => 'accept',
    provider => 'ip6tables',
  }

  firewall { '500 v6 accept heat cloudformation API':
    proto    => 'tcp',
    dport    => '8000',
    action   => 'accept',
    provider => 'ip6tables',
  }
}
