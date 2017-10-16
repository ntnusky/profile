# Configures iptables for neutron
class profile::openstack::neutron::firewall {
  firewall { '511 neutron-openvswi-INPUT':
    jump  => 'neutron-openvswi-INPUT',
    proto => 'all',
  }
}
