# Configures glance registry and backend
class profile::openstack::glance::registry {
  $region = hiera('profile::region')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')

  $memcached_ip = hiera('profile::memcache::ip')
  $mysql_pass = hiera('profile::mysql::glancepass')
  $mysql_ip = hiera('profile::mysql::ip')
  $database_connection = "mysql://glance:${mysql_pass}@${mysql_ip}/glance"

  require ::profile::openstack::repo
  require ::profile::openstack::glance::ceph
  require ::profile::openstack::glance::database

  class { '::glance::backend::rbd' :
    rbd_store_user => 'glance',
  }

  class { '::glance::registry':
    keystone_password   => $mysql_pass,
    database_connection => $database_connection,
    auth_strategy       => '',
  }

  class { '::glance::registry::authtoken':
    password          => $mysql_pass,
    auth_url          => "http://${keystone_admin_ip}:35357",
    auth_uri          => "http://${keystone_public_ip}:5000",
    memcached_servers => $memcached_ip,
    region_name       => $region,
  }
}
