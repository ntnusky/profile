# Configures neutron to use VLAN's for tenant networks
class profile::openstack::neutron::tenant::vlan {
  $tenant_if = hiera('profile::interfaces::tenant')
  $vlan_low = hiera('profile::neutron::vlan_low')
  $vlan_high = hiera('profile::neutron::vlan_high')

  require ::profile::openstack::repo
  require ::profile::openstack::neutron::base
  require ::vswitch::ovs

  if($tenant_if == 'vlan') {
    $a = 'It is impossible to use a VLAN for tenant_if when using VLANs to'
    $b = 'separate tenant networks.'
    fail("${a} ${b}")
  }

  class { '::profile::openstack::neutron::ovs':
    tenant_mapping => 'physnet-vlan:br-vlan',
  }

  class { '::neutron::plugins::ml2':
    type_drivers         => ['vlan', 'flat'],
    tenant_network_types => ['vlan'],
    mechanism_drivers    => ['openvswitch', 'l2population'],
    network_vlan_ranges  => ["physnet-vlan:${vlan_low}:${vlan_high}"],
  }

  vs_port { $tenant_if:
    ensure => present,
    bridge => 'br-vlan',
  }
}
