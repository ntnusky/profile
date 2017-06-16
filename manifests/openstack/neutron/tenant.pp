# Configures neutron for the appropriate tenant network strategy
class profile::openstack::neutron::tenant {
  $k = 'profile::neutron::tenant::network::type'
  $tenant_network_strategy = hiera($k)

  if($tenant_network_strategy == 'vlan') {
    include ::profile::openstack::neutron::tenant::vlan
  } elsif($tenant_network_strategy == 'vxlan') {
    include ::profile::openstack::neutron::tenant::vxlan
  } else {
    fail("The hiera key ${k} can only be 'vlan' or 'vxlan'")
  }
}
