# Configure firewall for rabbitmq servers
class profile::services::rabbitmq::firewall {
  require ::firewall

  $management_net = hiera('profile::networks::management::ipv4::prefix')
  $rabbitmq_ip = hiera('profile::rabbitmq::ip')
  $extra_net = hiera('profile::networks::management::ipv4::prefix::extra',false)

  firewall { '500 accept incoming rabbitmq':
    source      => $management_net,
    destination => $rabbitmq_ip,
    proto       => 'tcp',
    dport       => 5672,
    action      => 'accept',
  }

  if ($extra_net) {
    firewall { '501 accept incoming rabbitmq':
      source      => $extra_net,
      destination => $rabbitmq_ip,
      proto       => 'tcp',
      dport       => 5672,
      action      => 'accept',
    }
  }
}
