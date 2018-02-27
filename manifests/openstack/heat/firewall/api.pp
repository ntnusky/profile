# Configures the firewall to pass incoming traffic to the heat API.
class profile::openstack::heat::firewall::api {
  require ::profile::baseconfig::firewall

  $management_net = hiera('profile::networks::management::ipv4::prefix')

  firewall { '500 accept heat API':
    source      => $management_net,
    proto       => 'tcp',
    dport       => '8004',
    action      => 'accept',
  }

  firewall { '500 accept heat cloudformation API':
    source      => $management_net,
    proto       => 'tcp',
    dport       => '8000',
    action      => 'accept',
  }
}
