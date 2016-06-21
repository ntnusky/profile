class profile::openstack::glance {
  $password = hiera("profile::mysql::glancepass")
  $allowed_hosts = hiera("profile::mysql::allowed_hosts")
  $mysql_ip = hiera("profile::mysql::ip")
  $glance_key = hiera("profile::ceph::glance_key")
  $rabbit_ip = hiera("profile::rabbitmq::ip")

  $region = hiera("profile::region")
  $admin_ip = hiera("profile::api::glance::admin::ip")
  $public_ip = hiera("profile::api::glance::public::ip")
  $vrrp_password = hiera("profile::keepalived::vrrp_password")
  $vrid = hiera("profile::api::glance::vrrp::id")
  $vrpri = hiera("profile::api::glance::vrrp::priority")
  
  $rabbit_user = hiera("profile::rabbitmq::rabbituser")
  $rabbit_pass = hiera("profile::rabbitmq::rabbitpass")

  $database_connection = "mysql://glance:${password}@${mysql_ip}/glance"
  
  $public_if = hiera("profile::interfaces::public")
  $management_if = hiera("profile::interfaces::management")
  $management_ip = getvar("::ipaddress_${management_if}")
  
  include ::profile::openstack::repo
  
  anchor { "profile::openstack::glance::begin" : 
    require => [ Anchor["profile::mysqlcluster::end"], 
                 Anchor["profile::ceph::monitor::end"], ],
  }
  
  exec { "/usr/bin/ceph osd pool create images 4096" :
    unless => "/usr/bin/ceph osd pool get images size",
    before => Anchor['profile::openstack::glance::end'],
    require => [Anchor['profile::openstack::glance::begin'],
				Anchor['profile::ceph::monitor::end'],],
  }
  
  glance_api_config {
    'DEFAULT/default_store': value => "rbd";
  }
  
  class { '::glance::api':
    keystone_password   => $password,
    auth_host           => $admin_ip,
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    database_connection => $database_connection,
    registry_host       => $management_ip,
    os_region_name      => $region,
    before              => Anchor['profile::openstack::glance::end'],
    require             => Anchor['profile::openstack::glance::begin'],
    known_stores	=> ["glance.store.rbd.Store"],
    show_image_direct_url => true,
    pipeline            => 'keystone',
  }

  ceph_config {
      'client.glance/key':              value => $glance_key;
  }
  
  class { 'glance::backend::rbd' : 
    rbd_store_user      => 'glance',
    #rbd_store_ceph_conf => '/etc/ceph/ceph.client.glance.keyring',
    before              => Ceph::Key['client.glance'],
    require             => Anchor['profile::openstack::glance::begin'],
  }
  
  class { '::glance::registry':
    keystone_password   => $password,
    database_connection => $database_connection,
    auth_host           => $admin_ip,
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    mysql_module        => '2.2',
    before              => Anchor['profile::openstack::glance::end'],
    require             => Anchor['profile::openstack::glance::begin'],
  }
  
  class { '::glance::notify::rabbitmq':
    rabbit_password => $rabbit_pass,
    rabbit_userid   => $rabbit_user,
    rabbit_host     => $rabbit_ip,
    before          => Anchor['profile::openstack::glance::end'],
    require         => Anchor['profile::openstack::glance::begin'],
  }
  
  class  { '::glance::keystone::auth':
    password         => $password,
	public_url       => "http://${public_ip}:9292",
	internal_url     => "http://${admin_ip}:9292",
	admin_url        => "http://${admin_ip}:9292",
    region           => $region,
    before           => Anchor['profile::openstack::glance::end'],
    require          => Anchor['profile::openstack::glance::begin'],
  }
  
  class { 'glance::db::mysql' :
    password         => $password,
    allowed_hosts    => $allowed_hosts,
    before           => Anchor['profile::openstack::glance::end'],
    require          => Anchor['profile::openstack::glance::begin'],
  }
  keepalived::vrrp::script { 'check_glance':
    script => '/usr/bin/killall -0 glance-api',
    before           => Anchor['profile::openstack::glance::end'],
    require          => Anchor['profile::openstack::glance::begin'],
  }

  keepalived::vrrp::instance { 'admin-glance':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${admin_ip}/32",	
    ],
    track_script      => 'check_glance',
    before            => Anchor['profile::openstack::glance::end'],
    require           => Anchor['profile::openstack::glance::begin'],
    notify            => Service['keepalived'],
  }

  keepalived::vrrp::instance { 'public-glance':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${public_ip}/32",	
    ],
    track_script      => 'check_glance',
    before            => Anchor['profile::openstack::glance::end'],
    require           => Anchor['profile::openstack::glance::begin'],
    notify            => Service['keepalived'],
  }

  ceph::key { 'client.glance':
    secret        => $glance_key,
    cap_mon       => 'allow r',
    cap_osd       => 'allow class-read object_prefix rbd_children, allow rwx pool=images',
    inject        => true,
    before        => Anchor['profile::openstack::glance::end'],
    require       => Anchor['profile::openstack::glance::begin'],
  }
  
  anchor { "profile::openstack::glance::end" : }
}
