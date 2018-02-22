# Configures glance registry and backend
class profile::openstack::glance::registry {
  $region = hiera('profile::region')

  $admin_endpoint = hiera('profile::openstack::endpoint::admin', false)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', false)
  $public_endpoint = hiera('profile::openstack::endpoint::public', false)

  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $keystone_password = hiera('profile::glance::keystone::password')

  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")
  $keystone_public   = pick($public_endpoint, "http://${keystone_public_ip}")

  $memcached_ip = hiera('profile::memcache::ip')
  $mysql_pass = hiera('profile::mysql::glancepass')
  $mysql_ip = hiera('profile::mysql::ip')
  $database_connection = "mysql://glance:${mysql_pass}@${mysql_ip}/glance"

  require ::profile::openstack::glance::base
  contain ::profile::openstack::glance::ceph
  require ::profile::openstack::glance::database
  require ::profile::openstack::glance::firewall::server::registry
  require ::profile::openstack::repo

  class { '::glance::backend::rbd' :
    rbd_store_user => 'glance',
  }

  class { '::glance::registry':
    # Auth_strategy is blank to prevent glance::registry from including
    # ::glance::registry::authtoken.
    auth_strategy       => '',
    database_connection => $database_connection,
    keystone_password   => $keystone_password,
  }

  class { '::glance::registry::authtoken':
    password          => $keystone_password,
    auth_url          => "${keystone_admin}:35357",
    auth_uri          => "${keystone_public}:5000",
    memcached_servers => $memcached_ip,
    region_name       => $region,
  }
}
