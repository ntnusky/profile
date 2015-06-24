class profile::openstack::cinder {
  $password = hiera("profile::mysql::cinderpass")
  $keystone_password = hiera("profile::cinder::keystone::password")
  $allowed_hosts = hiera("profile::mysql::allowed_hosts")
  $mysql_ip = hiera("profile::mysql::ip")
  $ceph_key = hiera("profile::ceph::nova_key")
  $ceph_uuid = hiera("profile::ceph::nova_uuid")

  $region = hiera("profile::region")
  $keystone_admin_ip = hiera("profile::api::keystone::admin::ip")
  $keystone_admin_pass = hiera("profile::keystone::admin_password")
  $admin_ip = hiera("profile::api::cinder::admin::ip")
  $public_ip = hiera("profile::api::cinder::public::ip")
  $vrrp_password = hiera("profile::keepalived::vrrp_password")
  $vrid = hiera("profile::api::cinder::vrrp::id")
  $vrpri = hiera("profile::api::cinder::vrrp::priority")
  
  $rabbit_ip = hiera("profile::rabbitmq::ip")
  $rabbit_user = hiera("profile::rabbitmq::rabbituser")
  $rabbit_pass = hiera("profile::rabbitmq::rabbitpass")

  $database_connection = "mysql://cinder:${password}@${mysql_ip}/cinder"
  
  $public_if = hiera("profile::interfaces::public")
  $management_if = hiera("profile::interfaces::management")
  $management_ip = getvar("::ipaddress_${management_if}")
  
  include ::profile::openstack::repo
  
  anchor { "profile::openstack::cinder::begin" : 
    require => [ Anchor["profile::mysqlcluster::end"], 
                 Anchor["profile::ceph::monitor::end"], ],
  }
  
  ceph_config {
      'client.nova/key':              value => $ceph_key;
  }
  
  class { '::cinder':
    database_connection => $database_connection,
    rabbit_host         => $rabbit_ip,
    rabbit_userid       => $rabbit_user,
    rabbit_password     => $rabbit_pass,
    mysql_module        => '2.2',
  }
  
  class  { '::cinder::keystone::auth':
    password         => $password,
    public_address   => $public_ip,
    admin_address    => $admin_ip,
    internal_address => $admin_ip,
    region           => $region,
    before           => Anchor['profile::openstack::cinder::end'],
    require          => Anchor['profile::openstack::cinder::begin'],
  }
  
  class { '::cinder::db::mysql' :
    password         => $password,
    allowed_hosts    => $allowed_hosts,
    before           => Anchor['profile::openstack::cinder::end'],
    require          => Anchor['profile::openstack::cinder::begin'],
  }
  
  class { '::cinder::api':
    keystone_password  => $keystone_password,
    keystone_auth_host => $keystone_admin_ip,
    enabled            => true,
  }

  class { '::cinder::scheduler':
    scheduler_driver => 'cinder.scheduler.simple.SimpleScheduler',
    enabled          => true,
  }
  
  class { 'cinder::volume': }
  
  cinder::backend::rbd {'rbd-images':
    rbd_pool => 'images',
    rbd_user => 'nova',
  }
  
  Cinder::Type {
    os_password     => $keystone_admin_pass,
    os_tenant_name  => 'admin',
    os_username     => 'admin',
    os_auth_url     => 'http://127.0.0.1:5000/v2.0/',
  }
  
  cinder::type {'rbd':
    set_key   => 'rbd-images',
    set_value => 'rbd-images',
  }
  
  class { 'cinder::backends':
    enabled_backends => ['rbd-images']
  }

  keepalived::vrrp::script { 'check_cinder':
    script => '/usr/bin/killall -0 cinder-api',
    before           => Anchor['profile::openstack::cinder::end'],
    require          => Anchor['profile::openstack::cinder::begin'],
  }

  keepalived::vrrp::instance { 'admin-cinder':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${admin_ip}/32",	
    ],
    track_script      => 'check_cinder',
    before            => Anchor['profile::openstack::cinder::end'],
    require           => Anchor['profile::openstack::cinder::begin'],
    notify            => Service['keepalived'],
  }

  keepalived::vrrp::instance { 'public-cinder':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${public_ip}/32",	
    ],
    track_script      => 'check_cinder',
    before            => Anchor['profile::openstack::cinder::end'],
    require           => Anchor['profile::openstack::cinder::begin'],
    notify            => Service['keepalived'],
  }

  ceph::key { 'client.cinder':
    secret        => $ceph_key,
    cap_mon       => 'allow r',
    cap_osd       => 'allow class-read object_prefix rbd_children, allow rwx pool=cinder',
    inject        => true,
    before        => Anchor['profile::openstack::cinder::end'],
    require       => Anchor['profile::openstack::cinder::begin'],
  }
  
  anchor { "profile::openstack::cinder::end" : }
}
