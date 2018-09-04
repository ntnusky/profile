# Configure firewall for rabbitmq servers
class profile::services::rabbitmq::firewall {
  require ::firewall

  $management_net = hiera('profile::networks::management::ipv4::prefix')
  $rabbitmq_ip = hiera('profile::rabbitmq::ip')
  $extra_net = hiera('profile::networks::management::ipv4::prefix::extra',false)

  $enable_keepalived = hiera('profile::rabbitmq::keepalived::enable')
  if ( $enable_keepalived ) {
    $dest = $rabbitmq_ip
  } else {
    $dest = $::facts['networking']['ip']
  }

  firewall { '500 accept incoming rabbitmq':
    source      => $management_net,
    destination => $dest,
    proto       => 'tcp',
    dport       => 5672,
    action      => 'accept',
  }
  firewall { '502 accept incoming rabbitmqcluster':
    source      => $management_net,
    destination => $dest,
    proto       => 'tcp',
    dport       => 25672,
    action      => 'accept',
  }

  if ($extra_net) {
    firewall { '501 accept incoming rabbitmq':
      source      => $extra_net,
      destination => $dest,
      proto       => 'tcp',
      dport       => 5672,
      action      => 'accept',
    }
    firewall { '503 accept incoming rabbitmq':
      source      => $extra_net,
      destination => $dest,
      proto       => 'tcp',
      dport       => 25672,
      action      => 'accept',
    }
  }
}
