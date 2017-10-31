#Configures the firewall for the mysql servers
class profile::services::mysql::firewall::server {
  require ::firewall

  $management_net = hiera('profile::networks::management::ipv4::prefix')
  $management_if = hiera('profile::interfaces::management')
  $ip = $facts['networking']['interfaces'][$management_if]['ip']

  # We only accept incoming requests from the management-net, as all other
  # requests should come in trough the loadbalancers.
  firewall { '070 Accept incoming MySQL requests':
    proto       => 'tcp',
    dport       => 3306,
    action      => 'accept',
    source      => $management_net,
    destination => $ip,
  }

  firewall { '071 Accept incoming MySQL galera':
    proto       => 'tcp',
    dport       => [4567, 4568, 4444, 9000],
    action      => 'accept',
    source      => $management_net,
    destination => $ip,
  }

  firewall { '072 Accept incoming MySQL galera':
    proto       => 'udp',
    dport       => 4567,
    action      => 'accept',
    source      => $management_net,
    destination => $ip,
  }
}
