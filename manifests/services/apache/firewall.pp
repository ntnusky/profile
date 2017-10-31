# This class configures firewall rules for apache port 80,443
class profile::services::apache::firewall {
  require ::profile::baseconfig::firewall 
  firewall { '504 accept incoming HTTP, HTTPS':
    proto  => 'tcp',
    dport  => [80,443],
    action => 'accept',
  }
  firewall { '504 v6accept incoming HTTP, HTTPS':
    proto    => 'tcp',
    dport    => [80,443],
    action   => 'accept',
    provider => 'ip6tables',
  }
}
