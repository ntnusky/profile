# This class configures the neutron ml2 ovs agent.
class profile::openstack::neutron::ovs (
  $tenant_mapping,
  $local_ip         = undef,
  $tunnel_types     = undef,
) {
  $external_networks = hiera_array('profile::neutron::external::networks', [])

  $external = $external_networks.map |$net| {
    $bridge = hiera("profile::neutron::external::${net}::bridge")
    "${net}:${bridge}"
  }
                   
  $bridge_mappings = [ $tenant_mapping ]
  $mappings = concat($bridge_mappings, $external)

  class { '::neutron::agents::ml2::ovs':
    bridge_mappings => $mappings,
    local_ip        => $local_ip,
    tunnel_types    => $tunnel_types,
  }
}
