# Configures the neutron ml2 agent to use VXLAN for tenant traffic.
class profile::openstack::neutron::tenant::vxlan {
  $vni_low = hiera('profile::neutron::vni_low')
  $vni_high = hiera('profile::neutron::vni_high')
  $_tenant_if = hiera('profile::interfaces::tenant')

  require ::profile::openstack::repo
  require ::profile::openstack::neutron::base
  include ::profile::openstack::neutron::ovs
  require ::vswitch::ovs

  # Make sure there is allways an IP available for tunnel endpoints, even if the
  # correct IP is not present yet.
  $local_ip = pick($::ipaddress_br_provider, '169.254.254.254')

  if($_tenant_if == 'vlan') {
    $tenant_parent = hiera('profile::interfaces::tenant::parentif')
    $tenant_vlan = hiera('profile::interfaces::tenant::vlanid')
    $tenant_if = "br-vlan-${tenant_parent}"
  } else {
    $tenant_if = $_tenant_if
  }

  class { '::profile::openstack::neutron::ovs':
    tenant_mapping => 'provider:br-provider',
    local_ip       => $local_ip,
    tunnel_types   => ['vxlan'],
  }

  class { '::neutron::plugins::ml2':
    type_drivers         => ['vxlan', 'flat'],
    tenant_network_types => ['vxlan'],
    mechanism_drivers    => ['openvswitch', 'l2population'],
    vni_ranges           => "${vni_low}:${vni_high}"
  }

  if($_tenant_if == 'vlan') {
    $n = "${tenant_parent}-${tenant_vlan}-br-provider"
    ::profile::infrastructure::ovs::patch { $n :
      physical_if => $tenant_parent,
      vlan_id     => $tenant_vlan,
      ovs_bridge  => 'br-provider',
    }
  } else {
    vs_port { $tenant_if:
      ensure => present,
      bridge => 'br-provider',
    }
  }
}
