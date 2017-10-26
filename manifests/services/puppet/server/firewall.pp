# Configures the firewall for puppetmasters. 
class profile::services::puppet::server::firewall {
  require ::firewall

  firewall { '050 Accept incoming puppet':
    proto  => 'tcp',
    dport  => 8140,
    action => 'accept',
  }
  firewall { '050 ipv6 Accept incoming puppet':
    proto    => 'tcp',
    dport    => 8140,
    action   => 'accept',
    provider => 'ip6tables',
  }
}
