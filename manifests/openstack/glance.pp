class profile::openstack::glance {
  $password = hiera("profile::mysql::glancepass")
  $allowed_hosts = hiera("profile::mysql::allowed_hosts")
  $mysql_ip = hiera("profile::mysql::ip")
  $glance_key = hiera("profile::ceph::glance_key")

  $region = hiera("profile::region")
  $admin_ip = hiera("profile::api::glance::admin::ip")
  $public_ip = hiera("profile::api::glance::public::ip")
  
  $rabbit_user = hiera("profile::rabbitmq::rabbituser")
  $rabbit_pass = hiera("profile::rabbitmq::rabbitpass")

  $database_connection = "mysql://glance:${password}@${mysql_ip}/glance"
  
  include ::profile::openstack::repo
  
  anchor { "profile::openstack::glance::begin" : 
    require => [ Anchor["profile::mysqlcluster::end"], 
                 Anchor["profile::ceph::monitor::end"], ],
  }
  
  exec { "/usr/bin/ceph osd pool create images 2048" :
    unless => "/usr/bin/ceph osd pool get images size",
    before => Anchor['profile::openstack::glance::end'],
    require => Anchor['profile::openstack::glance::begin'],
  }
  
  class { '::glance::api':
    keystone_password   => $password,
    auth_host           => $admin_ip,
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    database_connection => $database_connection,
    registry_host       => $::ipaddress_eth1,
    os_region_name      => $region,
    before              => Anchor['profile::openstack::glance::end'],
    require             => Anchor['profile::openstack::glance::begin'],
    known_stores	=> ["glance.store.rbd.Store"],
  }
  
  class { 'glance::backend::rbd' : 
    rbd_store_user      => 'glance',
    rbd_store_ceph_conf => '/etc/ceph/ceph.client.glance.keyring',
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
    rabbit_host     => $admin_ip,
    before          => Anchor['profile::openstack::glance::end'],
    require         => Anchor['profile::openstack::glance::begin'],
  }
  
  class  { '::glance::keystone::auth':
    password         => $password,
    public_address   => $public_ip,
    admin_address    => $admin_ip,
    internal_address => $admin_ip,
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
    interface         => 'eth1',
    state             => 'MASTER',
    virtual_router_id => '52',
    priority          => '100',
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${admin_ip}/32",	
    ],
    track_script      => 'check_glance',
    before           => Anchor['profile::openstack::glance::end'],
    require          => Anchor['profile::openstack::glance::begin'],
  }

  keepalived::vrrp::instance { 'public-glance':
    interface         => 'eth0',
    state             => 'MASTER',
    virtual_router_id => '52',
    priority          => '100',
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${public_ip}/32",	
    ],
    track_script      => 'check_glance',
    before           => Anchor['profile::openstack::glance::end'],
    require          => Anchor['profile::openstack::glance::begin'],
  }

  ceph::key { 'client.glance':
    secret  => $glance_key,
    cap_mon => 'allow r',
    cap_osd => 'allow class-read object_prefix rbd_children, allow rwx pool=images',
    before           => Anchor['profile::openstack::glance::end'],
    require          => Anchor['profile::openstack::glance::begin'],
  }
  
  anchor { "profile::openstack::glance::end" : }
}
