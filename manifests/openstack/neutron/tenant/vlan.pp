# Configures neutron to use VLAN's for tenant networks
class profile::openstack::neutron::tenant::vlan {
  $tenant_if = hiera('profile::interfaces::tenant')

  require ::profile::openstack::repo
  require ::profile::openstack::neutron::base
  include ::profile::openstack::neutron::ml2::config
  require ::vswitch::ovs

  if($tenant_if == 'vlan') {
    $a = 'It is impossible to use a VLAN for tenant_if when using VLANs to'
    $b = 'separate tenant networks.'
    fail("${a} ${b}")
  }

  class { '::profile::openstack::neutron::ovs':
    tenant_mapping => 'physnet-vlan:br-vlan',
  }

  vs_port { $tenant_if:
    ensure => present,
    bridge => 'br-vlan',
  }
}
