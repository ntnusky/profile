# This class installs the neutron agents needed on a compute-node.
class profile::openstack::neutronagent {
  $password = hiera('profile::mysql::neutronpass')
  $keystone_ip = hiera('profile::api::keystone::public::ip')
  $mysql_ip = hiera('profile::mysql::ip')
  $neutron_pass = hiera('profile::neutron::keystone::password')
  $rabbit_ip = hiera('profile::rabbitmq::ip')

  $region = hiera('profile::region')
  $admin_ip = hiera('profile::api::neutron::admin::ip')
  $public_ip = hiera('profile::api::neutron::public::ip')
  $service_plugins = hiera('profile::neutron::service_plugins')

  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')

  $_tenant_if = hiera('profile::interfaces::tenant')

  $database_connection = "mysql://neutron:${password}@${mysql_ip}/neutron"
  $tenant_network_strategy = hiera('profile::neutron::tenant::network::type')

  require ::profile::openstack::repo

  if($_tenant_if == 'vlan') {
    $tenant_parent = hiera('profile::interfaces::tenant::parentif')
    $tenant_vlan = hiera('profile::interfaces::tenant::vlanid')
    $tenant_if = "br-vlan-${tenant_parent}"
  } else {
    $tenant_if = $_tenant_if
  }

  anchor{ 'profile::openstack::neutronagent::begin' : }
  anchor{ 'profile::openstack::neutronagent::end' : }

  if($tenant_network_strategy == 'vlan') {
    $vlan_low = hiera('profile::neutron::vlan_low')
    $vlan_high = hiera('profile::neutron::vlan_high')

    # This plugin configures Neutron for OVS on the server
    # Agent
    class { '::neutron::agents::ml2::ovs':
      bridge_mappings => ['physnet-vlan:br-vlan'],
      enabled         => true,
    }

    # ml2 plugin with vxlan as ml2 driver and ovs as mechanism driver
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

  if($tenant_network_strategy == 'vxlan') {
    $vni_low = hiera('profile::neutron::vni_low')
    $vni_high = hiera('profile::neutron::vni_high')

    class { '::neutron::agents::ml2::ovs':
      local_ip        => $::ipaddress_br_provider,
      bridge_mappings => ['provider:br-provider'],
      tunnel_types    => ['vxlan'],
    }
    class { '::neutron::plugins::ml2':
      type_drivers         => ['vxlan', 'flat'],
      tenant_network_types => ['vxlan'],
      mechanism_drivers    => ['openvswitch', 'l2population'],
      vni_ranges           => "${vni_low}:${vni_high}"
    }

    if($_tenant_if == 'vlan') {
      if ! defined(Profile::Infrastructure::Vlanbridge[$tenant_parent]) {
        ::profile::infrastructure::vlanbridge { $tenant_parent : }
      }

      $unless_args = "br-provider ${tenant_vlan} --verify"
      exec { "/usr/local/bin/addPatch.sh ${tenant_if} br-provider ${tenant_vlan}" :
        unless  => "/usr/local/bin/addPatch.sh ${tenant_if} ${unless_args}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        require => [
          File['/usr/local/bin/addPatch.sh'],
          Profile::Infrastructure::Vlanbridge[$tenant_parent],
        ],
      }
    } else {
      vs_port { $tenant_if:
        ensure => present,
        bridge => 'br-provider',
      }
    }
  }

  class { '::neutron':
    core_plugin           => 'ml2',
    allow_overlapping_ips => true,
    service_plugins       => $service_plugins,
    before                => Anchor['profile::openstack::neutronagent::end'],
    require               => Anchor['profile::openstack::neutronagent::begin'],
    rabbit_password       => $rabbit_pass,
    rabbit_user           => $rabbit_user,
    rabbit_host           => $rabbit_ip,
  }

#  class { '::neutron::keystone::auth':
#    password         => $neutron_pass,
#    public_address   => $public_ip,
#    admin_address    => $admin_ip,
#    internal_address => $admin_ip,
#    before           => Anchor['profile::openstack::neutronagent::end'],
#    require          => Anchor['profile::openstack::neutronagent::begin'],
#    region           => $region,
#  }

  class { '::neutron::server':
    enabled             => false,
    sync_db             => false,
    password            => $neutron_pass,
    auth_uri            => "http://${keystone_ip}:5000/",
    database_connection => $database_connection,
    before              => Anchor['profile::openstack::neutronagent::end'],
    require             => Anchor['profile::openstack::neutronagent::begin'],
  }

  neutron_l3_agent_config {
    'AGENT/extensions': value => 'fwaas';
  }

  sudo::conf { 'neutron_sudoers':
    ensure         => 'present',
    source         => 'puppet:///modules/profile/sudo/neutron_sudoers',
    sudo_file_name => 'neutron_sudoers',
  }
}
