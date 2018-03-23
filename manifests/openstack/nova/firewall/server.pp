# Configures the firewall to accept incoming traffic to the nova API. 
class profile::openstack::nova::firewall::server {
  $managementnet = hiera('profile::networks::management::ipv4::prefix')

  require ::profile::baseconfig::firewall

  firewall { '500 accept Nova API':
    source => $managementnet,
    proto  => 'tcp',
    dport  => '8774',
    action => 'accept',
  }

  firewall { '500 accept Nova placement API':
    source => $managementnet,
    proto  => 'tcp',
    dport  => '8778',
    action => 'accept',
  }

  firewall { '511 nova-api-INPUT':
    jump  => 'nova-api-INPUT',
    proto => 'all',
  }
}
