# This class configures the neutron ml2 ovs agent.
class profile::openstack::neutron::ovs (
  $tenant_mapping,
) {
  $external_networks = hiera_array('profile::neutron::external::networks', [])

  $bridge_mappings = [ $tenant_mapping ]
  
  $external_networks.each |$net| {
    $bridge = hiera("profile::neutron::external::${net}::bridge")
    concat($bridge_mapping, "${net}:${bridge}")
  }

  class { '::neutron::agents::ml2::ovs':
    bridge_mappings => $bridge_mappings,
  }
}
