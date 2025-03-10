# Configure firewall for rabbitmq servers
class profile::services::rabbitmq::firewall {
  $interregion = lookup('profile::rabbitmq::interregional', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  if($interregion) {
    ::profile::firewall::infra::all { 'RabbitMQ':
      port     => 5672,
    }
    ::profile::firewall::infra::all { 'RabbitMQ-Clustering':
      port     => [4369, 25672],
    }
    ::profile::firewall::infra::all { 'RabbitMQ-Clustering-CLI':
      port     => '35672-35682',
    }
  } else {
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
}
