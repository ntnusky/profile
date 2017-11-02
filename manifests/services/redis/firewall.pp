# Configure firewall for redis servers
class profile::services::redis::firewall {
  require ::firewall
  firewall { '050 accept redis-server':
    proto  => 'tcp',
    dport  => 6379,
    action => 'accept',
  }
  firewall { '050 ipv6 accept redis-server':
    proto    => 'tcp',
    dport    => 6379,
    action   => 'accept',
    provider => 'ip6tables',
  }
}
