class profile::openstack::neutronserver {
  $password = hiera("profile::mysql::neutronpass")
  $neutron_password = hiera("profile::neutron::keystone::password")
  $nova_password = hiera("profile::nova::keystone::password")
  $allowed_hosts = hiera("profile::mysql::allowed_hosts")
  $keystone_public_ip = hiera("profile::api::keystone::public::ip")
  $keystone_admin_ip = hiera("profile::api::keystone::admin::ip")
  $mysql_ip = hiera("profile::mysql::ip")

  $region = hiera("profile::region")
  $admin_ip = hiera("profile::api::neutron::admin::ip")
  $public_ip = hiera("profile::api::neutron::public::ip")
  $vrid = hiera("profile::api::neutron::vrrp::id")
  $vrpri = hiera("profile::api::neutron::vrrp::priority")
  $vrrp_password = hiera("profile::keepalived::vrrp_password")
  $nova_admin_ip = hiera("profile::api::nova::admin::ip")
  $nova_public_ip = hiera("profile::api::nova::public::ip")
  $service_plugins = hiera("profile::neutron::service_plugins")
  $neutron_vrrp_pass = hiera("profile::neutron::vrrp_pass")
  $nova_metadata_secret = hiera("profile::nova::sharedmetadataproxysecret")
  $dns_servers = hiera("profile::nova::dns")

  $vlan_low = hiera("profile::neutron::vlan_low")
  $vlan_high = hiera("profile::neutron::vlan_high")
  
  $public_if = hiera("profile::interfaces::public")
  $management_if = hiera("profile::interfaces::management")
  $external_if = hiera("profile::interfaces::external")
  $tenant_if = hiera("profile::interfaces::tenant")

  $rabbit_user = hiera("profile::rabbitmq::rabbituser")
  $rabbit_pass = hiera("profile::rabbitmq::rabbitpass")
  $rabbit_ip = hiera("profile::rabbitmq::ip")

  $database_connection = "mysql://neutron:${password}@${mysql_ip}/neutron"
  
  include ::profile::openstack::repo
  
  anchor { "profile::openstack::neutron::begin" : 
    require => [ Anchor["profile::mysqlcluster::end"], ],
  }
  
  class { '::neutron':
    verbose                 => true,
    core_plugin             => 'ml2',
    allow_overlapping_ips   => true,
    service_plugins         => $service_plugins,
	dhcp_agents_per_network => 2,
    before                  => Anchor['profile::openstack::neutron::end'],
    require                 => Anchor['profile::openstack::neutron::begin'],
    rabbit_password         => $rabbit_pass,
    rabbit_user             => $rabbit_user,
    rabbit_host             => $rabbit_ip,
  }
  
  class { 'neutron::db::mysql' :
    password         => $password,
    allowed_hosts    => $allowed_hosts,
    before           => Anchor['profile::openstack::neutron::end'],
    require          => Anchor['profile::openstack::neutron::begin'],
  }
  
#  neutron_config {
#    'DEFAULT/l3_ha': value => 'true';
#    'DEFAULT/max_l3_agents_per_router': value => '3';
#    'DEFAULT/min_l3_agents_per_router': value => '2';
#  }

  class { '::neutron::keystone::auth':
    password         => $neutron_password,
	public_url       => "http://${public_ip}:9696",
	internal_url     => "http://${admin_ip}:9696",
	admin_url        => "http://${admin_ip}:9696",
    before           => Anchor["profile::openstack::neutron::end"],
    require          => Anchor["profile::openstack::neutron::begin"],
    region           => $region,
  }

  class { '::neutron::agents::metadata':
    shared_secret => $nova_metadata_secret,
    metadata_ip   => $admin_ip,
    enabled       => true,
  }
  
  class { '::neutron::server':
    auth_password       => $neutron_password,
    auth_uri            => "http://${keystone_public_ip}:5000/",
    auth_url            => "http://${keystone_admin_ip}:35357/",
    database_connection => $database_connection,
    sync_db             => true,
    before              => Anchor["profile::openstack::neutron::end"],
    require             => Anchor["profile::openstack::neutron::begin"],
  }
  
  class { '::neutron::agents::dhcp':
    #enabled            => false,
    #manage_service     => false,
	dnsmasq_dns_servers => $dns_servers,
    before         => Anchor["profile::openstack::neutron::end"],
    require        => Anchor["profile::openstack::neutron::begin"],
  }

  # Configure nova notifications system
  class { '::neutron::server::notifications':
    password       => $nova_password,
    auth_url       => "http://${keystone_admin_ip}:35357",
    region_name    => $region,
	nova_url       => "http://${nova_public_ip}:8774/v2",
    before         => Anchor["profile::openstack::neutron::end"],
    require        => Class["::nova::keystone::auth"],
  }

  # This plugin configures Neutron for OVS on the server
  # Agent
  class { '::neutron::agents::ml2::ovs':
    bridge_mappings  => ['external:br-ex','physnet-vlan:br-vlan'],
    before           => Anchor["profile::openstack::neutron::end"],
    require          => Anchor["profile::openstack::neutron::begin"],
  }

  # ml2 plugin with vxlan as ml2 driver and ovs as mechanism driver
  class { '::neutron::plugins::ml2':
    type_drivers         => ['vlan', 'flat'],
    tenant_network_types => ['vlan'],
    mechanism_drivers    => ['openvswitch'],
    network_vlan_ranges  => ["physnet-vlan:${vlan_low}:${vlan_high}"],
    before         => Anchor["profile::openstack::neutron::end"],
    require        => Anchor["profile::openstack::neutron::begin"],
  }
  
  class { '::neutron::agents::l3':
    before                           => Anchor["profile::openstack::neutron::end"],
    require                          => Anchor["profile::openstack::neutron::begin"],
    allow_automatic_l3agent_failover => true,
    ha_enabled                       => true,
    ha_vrrp_auth_password            => $neutron_vrrp_pass,
  }
  
  vs_port { $external_if:
    ensure => present,
    bridge => "br-ex",
  }
 # vs_bridge { "br-vlan":
 #   ensure => present,
 # } ->
  vs_port { $tenant_if:
    ensure => present,
    bridge => "br-vlan",
  }

  keepalived::vrrp::script { 'check_neutron':
    require        => Anchor["profile::openstack::neutron::begin"],
    script => '/usr/bin/killall -0 neutron-server',
  } ->

  keepalived::vrrp::instance { 'admin-neutron':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${admin_ip}/32",	
    ],
    track_script      => 'check_keystone',
  } ->

  keepalived::vrrp::instance { 'public-neutron':
    before            => Anchor["profile::openstack::neutron::end"],
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${public_ip}/32",	
    ],
    track_script      => 'check_keystone',
  }
  
#  cs_primitive { 'neutron_public_ip':
#    primitive_class => 'ocf',
#    primitive_type  => 'IPaddr2',
#    provided_by     => 'heartbeat',
#    parameters      => { 'ip' => $public_ip, 'cidr_netmask' => '24' },
#    operations      => { 'monitor' => { 'interval' => '2s' } },
#  }
#  
#  cs_primitive { 'neutron_private_ip':
#    primitive_class => 'ocf',
#    primitive_type  => 'IPaddr2',
#    provided_by     => 'heartbeat',
#    parameters      => { 'ip' => $private_ip, 'cidr_netmask' => '24' },
#    operations      => { 'monitor' => { 'interval' => '2s' } },
#  }
  
  anchor { "profile::openstack::neutron::end" : }
}
