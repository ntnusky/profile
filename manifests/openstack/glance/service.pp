# Configures glance registry and backend
class profile::openstack::glance::service {
  $region = hiera('profile::region')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')

  $rabbit_ip = hiera('profile::rabbitmq::ip')
  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')

  $memcached_ip = hiera('profile::memcache::ip')
  $mysql_pass = hiera('profile::mysql::glancepass')
  $mysql_ip = hiera('profile::mysql::ip')
  $database_connection = "mysql://glance:${mysql_pass}@${mysql_ip}/glance"

  require ::profile::services::rabbitmq
  require ::profile::openstack::repo
  require ::profile::openstack::glance::ceph

  class { '::glance::backend::rbd' :
    rbd_store_user => 'glance',
  }

  glance_api_config {
    'DEFAULT/default_store': value => 'rbd';
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

  class { '::glance::notify::rabbitmq':
    rabbit_password => $rabbit_pass,
    rabbit_userid   => $rabbit_user,
    rabbit_host     => $rabbit_ip,
  }
}
