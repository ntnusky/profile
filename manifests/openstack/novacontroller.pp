class profile::openstack::novacontroller {
  $mysql_password = hiera("profile::mysql::novapass")
  $allowed_hosts = hiera("profile::mysql::allowed_hosts")
  $keystone_ip = hiera("profile::api::keystone::public::ip")
  $mysql_ip = hiera("profile::mysql::ip")
  $controllers = hiera("controller::management::addresses")

  $region = hiera("profile::region")
  $neutron_admin_ip = hiera("profile::api::neutron::admin::ip")
  $nova_admin_ip = hiera("profile::api::nova::admin::ip")
  $nova_public_ip = hiera("profile::api::nova::public::ip")
  $glance_admin_ip = hiera("profile::api::glance::admin::ip")
  $glance_public_ip = hiera("profile::api::glance::public::ip")
  $nova_secret = hiera("profile::nova::sharedmetadataproxysecret")
  $nova_password = hiera("profile::nova::keystone::password")
  $neutron_password = hiera("profile::neutron::keystone::password")
  $vrid = hiera("profile::api::nova::vrrp::id")
  $vrpri = hiera("profile::api::nova::vrrp::priority")
  $vrrp_password = hiera("profile::keepalived::vrrp_password")
  $vnc_proxy_ip = hiera("nova::vncproxy::common::vncproxy_host")
  
  $rabbit_user = hiera("profile::rabbitmq::rabbituser")
  $rabbit_pass = hiera("profile::rabbitmq::rabbitpass")
  $rabbit_ip = hiera("profile::rabbitmq::ip")

  $public_if = hiera("profile::interfaces::public")
  $management_if = hiera("profile::interfaces::management")

  $database_connection = "mysql://nova:${mysql_password}@${mysql_ip}/nova"
  $sync_db = hiera("profile::nova::sync_db")
  
  include ::profile::openstack::repo
  
  anchor { "profile::openstack::novacontroller::begin" : 
    require => [ Anchor["profile::mysqlcluster::end"], ],
  }
  
  class { '::nova::keystone::auth':
    password         => $nova_password,
	public_url       => "http://${nova_public_ip}:8774/v2/%(tenant_id)s",
	internal_url     => "http://${nova_admin_ip}:8774/v2/%(tenant_id)s",
	admin_url        => "http://${nova_admin_ip}:8774/v2/%(tenant_id)s",
	public_url_v3    => "http://${nova_public_ip}:8774/v3",
	internal_url_v3  => "http://${nova_admin_ip}:8774/v3",
	admin_url_v3     => "http://${nova_admin_ip}:8774/v3",
	ec2_public_url   => "http://${nova_public_ip}:8773/services/Cloud",
	ec2_internal_url => "http://${nova_admin_ip}:8773/services/Cloud",
	ec2_admin_url    => "http://${nova_admin_ip}:8773/services/Admin",
    region           => $region,
    before           => Anchor["profile::openstack::novacontroller::end"],
    require          => Anchor["profile::openstack::novacontroller::begin"],
  }

  class { 'nova::db::mysql' :
    password         => $mysql_password,
    allowed_hosts    => $allowed_hosts,
    before           => Anchor['profile::openstack::novacontroller::end'],
    require          => Anchor['profile::openstack::novacontroller::begin'],
  }
  
  class { 'nova':
    database_connection => $database_connection,
    rabbit_userid       => $rabbit_user,
    rabbit_password     => $rabbit_pass,
    image_service       => 'nova.image.glance.GlanceImageService',
    glance_api_servers  => "${glance_public_ip}:9292",
    rabbit_host         => $rabbit_ip,
    before              => Anchor["profile::openstack::novacontroller::end"],
    require             => Anchor["profile::openstack::novacontroller::begin"],
  }
  
  class { 'nova::api':
    admin_password                       => $nova_password,
    api_bind_address                     => $nova_public_ip,
    auth_uri                             => "http://${$keystone_ip}:5000/",
    neutron_metadata_proxy_shared_secret => $nova_secret,
    sync_db		=> $sync_db,
    before              => Anchor["profile::openstack::novacontroller::end"],
    require             => Anchor["profile::openstack::novacontroller::begin"],
    enabled		=> true,
  }
  
  class { 'nova::network::neutron':
    neutron_admin_password    => $neutron_password,
    neutron_url               => "http://${neutron_admin_ip}:9696",
    neutron_admin_auth_url    => "http://${keystone_ip}:35357/v2.0",
    before              => Anchor["profile::openstack::novacontroller::end"],
    require             => Anchor["profile::openstack::novacontroller::begin"],
  }
  
  class { 'nova::vncproxy':
    host    => $vnc_proxy_ip,
    before              => Anchor["profile::openstack::novacontroller::end"],
    require             => Anchor["profile::openstack::novacontroller::begin"],
    enabled		=> true,
  }
  
  class { [
    'nova::scheduler',
    #'nova::objectstore',
    'nova::cert',
    'nova::consoleauth',
    'nova::conductor'
  ]:
    before              => Anchor["profile::openstack::novacontroller::end"],
    require             => Anchor["profile::openstack::novacontroller::begin"],
    enabled		=> true,
  }

  keepalived::vrrp::script { 'check_nova':
    require             => Anchor["profile::openstack::novacontroller::begin"],
    script => '/usr/bin/killall -0 nova-api',
  } ->

  keepalived::vrrp::instance { 'admin-nova':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${nova_admin_ip}/32",	
    ],
    track_script      => 'check_nova',
  } ->

  keepalived::vrrp::instance { 'public-nova':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${nova_public_ip}/32",	
    ],
    track_script      => 'check_nova',
    before              => Anchor["profile::openstack::novacontroller::end"],
  }
  
  anchor { "profile::openstack::novacontroller::end" : }
}
