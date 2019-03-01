# Configure firewall for rabbitmq servers
class profile::services::rabbitmq::firewall {
  ::profile::baseconfig::firewall::service::infra { 'RabbitMQ':
    protocol => 'tcp',
    port     => 5672,
  }
  ::profile::baseconfig::firewall::service::infra { 'RabbitMQ-Clustering':
    protocol => 'tcp',
    port     => [4369, 25672],
  }
  ::profile::baseconfig::firewall::service::infra { 'RabbitMQ-Clustering-CLI':
    protocol => 'tcp',
    port     => '35672-35682',
  }
}
