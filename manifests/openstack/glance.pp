class profile::openstack::glance {
  $password = hiera("profile::mysql::glancepass")
  $allowed_hosts = hiera("profile::mysql::allowed_hosts")
  $mysql_ip = hiera("profile::mysql::ip")

  $region = hiera("profile::region")
  $admin_ip = hiera("profile::api::admin::ip")
  $public_ip = hiera("profile::api::public::ip")
  
  $rabbit_user = hiera("profile::rabbitmq::rabbituser")
  $rabbit_pass = hiera("profile::rabbitmq::rabbitpass")

  $database_connection = "mysql://glance:${password}@${mysql_ip}/glance"
  
  include ::profile::openstack::repo
  
  anchor { "profile::openstack::glance::begin" : }
  
  exec { "/usr/bin/ceph pool create images 2048" :
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
  }
  
  class { 'glance::backend::rbd' : 
    before              => Anchor['profile::openstack::glance::end'],
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
  
  anchor { "profile::openstack::glance::end" : }
}
