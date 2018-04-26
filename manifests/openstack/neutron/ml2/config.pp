# Configures neutron for the ML2 plugin.
class profile::openstack::neutron::ml2::config {
  $k = 'profile::neutron::tenant::network::type'
  $tenant_network_strategy = hiera($k)

  if($tenant_network_strategy == 'vlan') {
    $vlan_low = hiera('profile::neutron::vlan_low')
    $vlan_high = hiera('profile::neutron::vlan_high')

    class { '::neutron::plugins::ml2':
      type_drivers         => ['vlan', 'flat'],
      tenant_network_types => ['vlan'],
      mechanism_drivers    => ['openvswitch', 'l2population'],
      network_vlan_ranges  => ["physnet-vlan:${vlan_low}:${vlan_high}"],
    }
  } elsif($tenant_network_strategy == 'vxlan') {
    $vni_low = hiera('profile::neutron::vni_low')
    $vni_high = hiera('profile::neutron::vni_high')

    class { '::neutron::plugins::ml2':
      type_drivers         => ['vxlan', 'flat'],
      tenant_network_types => ['vxlan'],
      mechanism_drivers    => ['openvswitch', 'l2population'],
      vni_ranges           => "${vni_low}:${vni_high}"
    }
  } else {
    fail("The hiera key ${k} can only be 'vlan' or 'vxlan'")
  }
}
