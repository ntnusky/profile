# Configures iptables for nova
class profile::openstack::nova::firewall {
  firewall { '511 nova-api-INPUT':
    jump  => 'nova-api-INPUT',
    proto => 'all',
  }
}
