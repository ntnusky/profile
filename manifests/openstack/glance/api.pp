# Installs and configures the glance API
class profile::openstack::glance::api {
  $region = hiera('profile::region')
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)

  $adminlb_ip = hiera('profile::haproxy::management::ipv4', undef)

  $glance_public_ip = hiera('profile::api::glance::public::ip')
  $glance_admin_ip = hiera('profile::api::glance::admin::ip')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $keystone_password = hiera('profile::glance::keystone::password')

  $admin_endpoint = hiera('profile::openstack::endpoint::admin', false)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', false)
  $public_endpoint = hiera('profile::openstack::endpoint::public', false)

  $glance_admin    = pick($admin_endpoint, "http://${glance_admin_ip}")
  $glance_internal = pick($internal_endpoint, "http://${glance_admin_ip}")
  $glance_public   = pick($public_endpoint, "http://${glance_public_ip}")
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")
  $keystone_public   = pick($public_endpoint, "http://${keystone_public_ip}")

  $memcached_ip = hiera('profile::memcache::ip')

  $management_if = hiera('profile::interfaces::management')
  $management_ip = hiera("profile::interfaces::${management_if}::address")

  $mysql_pass = hiera('profile::mysql::glancepass')
  $mysql_ip = hiera('profile::mysql::ip')
  $database_connection = "mysql://glance:${mysql_pass}@${mysql_ip}/glance"

  require ::profile::openstack::repo
  require ::profile::openstack::glance::database
  require ::profile::openstack::glance::firewall::server::api
  contain ::profile::openstack::glance::keepalived

  if($confhaproxy) {
    contain ::profile::openstack::keystone::haproxy::backend::server
  }

  class { '::glance::api':
    # Auth_strategy is blank to prevent glance::api from including
    # ::glance::api::authtoken.
    auth_strategy           => '',
    database_connection     => $database_connection,
    keystone_password       => $keystone_password,
    known_stores            => ['glance.store.rbd.Store'],
    os_region_name          => $region,
    registry_host           => pick($adminlb_ip, $management_ip),
    show_image_direct_url   => true,
    show_multiple_locations => true,
  }

  class { '::glance::api::authtoken':
    password          => $keystone_password,
    auth_url          => "${keystone_admin}:35357",
    auth_uri          => "${keystone_public}:5000",
    memcached_servers => $memcached_ip,
    region_name       => $region,
  }

  class  { '::glance::keystone::auth':
    password     => $keystone_password,
    public_url   => "${glance_public}:9292",
    internal_url => "${glance_internal}:9292",
    admin_url    => "${glance_admin}:9292",
    region       => $region,
  }

  glance_api_config {
    'DEFAULT/default_store': value => 'rbd';
  }
}
