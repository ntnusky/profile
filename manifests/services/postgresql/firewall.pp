#Configures the firewall for the postgres servers
class profile::services::postgresql::firewall {
  require ::firewall

  $management_net = hiera('profile::networks::management::ipv4::prefix')
  $management_netv6 = hiera('profile::networks::management::ipv6::prefix', false)
  $management_if = hiera('profile::interfaces::management')
  $ip = $facts['networking']['interfaces'][$management_if]['ip']
  $postgresql_ipv4 = hiera('profile::postgres::ipv4')
  $postgresql_ipv6 = hiera('profile::postgres::ipv6', false)

  # We limit incoming requests to the management-network as it is only puppetdb
  # servers which needs postgres, and these live on this network.
  firewall { '070 Accept incoming postgres requests':
    proto       => 'tcp',
    dport       => 5432,
    action      => 'accept',
    source      => $management_net,
    destination => $ip,
  }
  firewall { '071 Accept incoming postgres requests':
    proto       => 'tcp',
    dport       => 5432,
    action      => 'accept',
    source      => $management_net,
    destination => $postgresql_ipv4,
  }
  if($postgresql_ipv6) {
    firewall { '071 ipv6 Accept incoming postgres requests':
      proto       => 'tcp',
      dport       => 5432,
      action      => 'accept',
      source      => $management_netv6,
      destination => $postgresql_ipv6,
      provider    => 'ip6tables',
    }
  }
}
