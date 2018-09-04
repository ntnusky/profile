# Configure firewall for rabbitmq servers
class profile::services::rabbitmq::firewall {
  require ::firewall

  $management_net = hiera('profile::networks::management::ipv4::prefix')
  $management_netv6 = hiera('profile::networks::management::ipv6::prefix', false)
  $rabbitmq_ip = hiera('profile::rabbitmq::ip')
  $rabbitmq_ipv6 = hiera('profile::rabbitmq::ipv6', false)
  $extra_net = hiera('profile::networks::management::ipv4::prefix::extra',false)

  $enable_keepalived = hiera('profile::rabbitmq::keepalived::enable')
  if ( $enable_keepalived ) {
    $destv4 = $rabbitmq_ip
    $destv6 = $rabbitmq_ipv6
  } else {
    $destv4 = $::facts['networking']['ip']
    $destv6 = $::facts['networking']['ip6']
  }

  firewall { '500 accept incoming rabbitmq':
    source      => $management_net,
    destination => $destv4,
    proto       => 'tcp',
    dport       => 5672,
    action      => 'accept',
  }
  firewall { '502 accept incoming rabbitmqcluster':
    source      => $management_net,
    destination => $destv4,
    proto       => 'tcp',
    dport       => [4369, 25672],
    action      => 'accept',
  }
  if ( $management_netv6 ) {
    firewall { '500 ipv6 accept incoming rabbitmq':
      source      => $management_netv6,
      destination => $destv6,
      proto       => 'tcp',
      dport       => 5672,
      action      => 'accept',
      provider    => 'ip6tables',
    }
    firewall { '502 ipv6 accept incoming rabbitmqcluster':
      source      => $management_netv6,
      destination => $destv6,
      proto       => 'tcp',
      dport       => [4369, 25672],
      action      => 'accept',
      provider    => 'ip6tables',
    }
  }

  if ($extra_net) {
    firewall { '501 accept incoming rabbitmq':
      source      => $extra_net,
      destination => $destv4,
      proto       => 'tcp',
      dport       => 5672,
      action      => 'accept',
    }
    firewall { '503 accept incoming rabbitmq':
      source      => $extra_net,
      destination => $destv4,
      proto       => 'tcp',
      dport       => 25672,
      action      => 'accept',
    }
  }
}
