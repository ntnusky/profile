#Configures the firewall for the postgres servers
class profile::services::postgresql::firewall {
  require ::firewall

  $management_net = hiera('profile::networks::management')
  $management_if = hiera('profile::interfaces::management')
  $ip = $facts['networking']['interfaces'][$management_if]['ip']
  $postgresql_ip = hiera('profile::postgres::ip')

  # We limit incoming requests to the management-network as it is only puppetdb
  # servers which needs postgres, and these live on this network.
  firewall { '070 Accept incoming postgres requests':
    proto       => 'tcp',
    dport       => 5432,
    action      => 'accept',
    source      => $management_net,
    destination => [$ip, $postgresql_ip],
  }
}
