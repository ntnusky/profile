# Installs and configures the neutron service on an openstack controller node
# in the SkyHiGh architecture. This class installs both the API and the neutron
# agents.
class profile::openstack::neutron::tenant::vxlan {
  $vni_low = hiera('profile::neutron::vni_low')
  $vni_high = hiera('profile::neutron::vni_high')
  $_tenant_if = hiera('profile::interfaces::tenant')

  require ::profile::openstack::repo

  $local_ip = pick($::ipaddress_br_provider, '169.254.254.254')

  if($_tenant_if == 'vlan') {
    $tenant_parent = hiera('profile::interfaces::tenant::parentif')
    $tenant_vlan = hiera('profile::interfaces::tenant::vlanid')
    $tenant_if = "br-vlan-${tenant_parent}"
  } else {
    $tenant_if = $_tenant_if
  }

  Class { '::neutron::agents::ml2::ovs':
    local_ip     => $local_ip,
    tunnel_types => ['vxlan'],
  }

  class { '::profile::openstack::neutron::ovs':
    tenant_mapping => 'provider:br-provider',
  }

  class { '::neutron::plugins::ml2':
    type_drivers         => ['vxlan', 'flat'],
    tenant_network_types => ['vxlan'],
    mechanism_drivers    => ['openvswitch', 'l2population'],
    vni_ranges           => "${vni_low}:${vni_high}"
  }

  if($_tenant_if == 'vlan') {
    ::profile::infrastructure::ovs::patch {
      $physical_if => $tenant_parent,
      $vlan_id     => $tenant_vlan,
      $ovs_bridge  => 'br-provider',
    }
  } else {
    vs_port { $tenant_if:
      ensure => present,
      bridge => 'br-provider',
    }
  }
}
