# Configures the firewall for puppetmasters. 
class profile::services::puppet::db::firewall {
  require ::firewall

  firewall { '051 Accept incoming puppetdb':
    proto  => 'tcp',
    dport  => 8081,
    action => 'accept',
  }
}
