# Configures iptables for nova
class profile::openstack::nova::firewall {
  firewall { 'nova-api-INPUT':
    jump => 'nova-api-INPUT',
  }
}
