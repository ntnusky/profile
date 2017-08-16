# This class configures firewall rules for apache port 80,443
class profile::services::apache::firewall {
  firewall { '504 accept incoming HTTP, HTTPS':
    proto  => 'tcp',
    dport  => [80,443],
    action => 'accept',
  }
  require ::profile::baseconfig::firewall 
}
