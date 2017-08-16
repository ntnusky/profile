# Configures iptables for nova
class profile::openstack::nove::firewall {
  firewall { 'nova-api-INPUT':
    jump => 'nova-api-INPUT',
  }
}
