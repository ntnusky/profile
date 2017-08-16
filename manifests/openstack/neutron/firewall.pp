# Configures iptables for neutron
class profile::openstack::neutron::firewall {
  firewall { 'neutron-openvswi-INPUT':
    jump => 'neutron-openvswi-INPUT',
  }
}
