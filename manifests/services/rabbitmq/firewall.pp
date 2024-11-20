# Configure firewall for rabbitmq servers
class profile::services::rabbitmq::firewall {
  ::profile::firewall::infra::region { 'RabbitMQ':
    port     => 5672,
  }
  ::profile::firewall::infra::region { 'RabbitMQ-Clustering':
    port     => [4369, 25672],
  }
  ::profile::firewall::infra::region { 'RabbitMQ-Clustering-CLI':
    port     => '35672-35682',
  }
}
