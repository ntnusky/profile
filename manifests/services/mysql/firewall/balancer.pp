#Configures the firewall for the mysql loadbalancers
class profile::services::mysql::firewall::balancer {
  ::profile::baseconfig::firewall::service::infra { 'MYSQL':
    protocol => 'tcp',
    port     => 3306,
  }
}
