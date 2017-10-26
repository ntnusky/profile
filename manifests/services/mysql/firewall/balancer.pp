#Configures the firewall for the mysql loadbalancers
class profile::services::mysql::firewall::balancer {
  require ::firewall

  firewall { '071 Accept incoming MySQL requests':
    proto       => 'tcp',
    dport       => 3306,
    action      => 'accept',
  }
}
