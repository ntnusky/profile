class profile::openstack::neutronagent {
  $password = hiera("profile::mysql::neutronpass")
  $keystone_ip = hiera("profile::api::keystone::public::ip")
  $mysql_ip = hiera("profile::mysql::ip")
  $neutron_pass = hiera("profile::neutron::keystone::password")
  $rabbit_ip = hiera("profile::rabbitmq::ip")

  $region = hiera("profile::region")
  $admin_ip = hiera("profile::api::neutron::admin::ip")
  $public_ip = hiera("profile::api::neutron::public::ip")
  $service_plugins = hiera("profile::neutron::service_plugins")
  
  $rabbit_user = hiera("profile::rabbitmq::rabbituser")
  $rabbit_pass = hiera("profile::rabbitmq::rabbitpass")
  $vlan_low = hiera("profile::neutron::vlan_low")
  $vlan_high = hiera("profile::neutron::vlan_high")

  $tenant_if = hiera("profile::interface::tenant")

  $database_connection = "mysql://neutron:${password}@${mysql_ip}/neutron"
  
  include ::profile::openstack::repo
  
  anchor{ "profile::openstack::neutronagent::begin" : }
  anchor{ "profile::openstack::neutronagent::end" : }

  class { '::neutron::agents::ml2::ovs':
    enabled          => true,
    bridge_mappings  => ['physnet-vlan:br-vlan'],
    before           => Anchor["profile::openstack::neutronagent::end"],
    require          => Anchor["profile::openstack::neutronagent::begin"],
  }

  class { '::neutron::plugins::ml2':
    type_drivers         => ['vlan', 'flat'],
    tenant_network_types => ['vlan'],
    mechanism_drivers    => ['openvswitch'],
    network_vlan_ranges  => ["physnet-vlan:${vlan_low}:${vlan_high}"],
    before         => Anchor["profile::openstack::neutronagent::end"],
    require        => Anchor["profile::openstack::neutronagent::begin"],
  }
  
  vs_port { $tenant_if:
    ensure => present,
    bridge => "br-vlan",
  }

  class { '::neutron':
    core_plugin           => 'ml2',
    allow_overlapping_ips => true,
    service_plugins       => $service_plugins,
    before                => Anchor["profile::openstack::neutronagent::end"],
    require               => Anchor["profile::openstack::neutronagent::begin"],
    rabbit_password       => $rabbit_pass,
    rabbit_user           => $rabbit_user,
    rabbit_host           => $rabbit_ip,
  }
  
#  class { '::neutron::keystone::auth':
#    password         => $neutron_pass,
#    public_address   => $public_ip,
#    admin_address    => $admin_ip,
#    internal_address => $admin_ip,
#    before           => Anchor["profile::openstack::neutronagent::end"],
#    require          => Anchor["profile::openstack::neutronagent::begin"],
#    region           => $region,
#  }
  
  class { '::neutron::server':
    enabled           => false,
    sync_db           => false,
    auth_password     => $neutron_pass,
    auth_uri          => "http://${keystone_ip}:5000/",
    connection        => $database_connection,
    before            => Anchor["profile::openstack::neutronagent::end"],
    require           => Anchor["profile::openstack::neutronagent::begin"],
  }
}
