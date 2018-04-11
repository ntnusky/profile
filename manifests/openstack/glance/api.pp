# Installs and configures the glance API
class profile::openstack::glance::api {
  # Determine where the database is
  $mysql_pass = hiera('profile::mysql::glancepass')
  $mysql_old = hiera('profile::mysql::ip', undef)
  $mysql_new = hiera('profile::haproxy::management::ipv4', undef)
  $mysql_ip = pick($mysql_new, $mysql_old)
  $database_connection = "mysql://glance:${mysql_pass}@${mysql_ip}/glance"

  # Openstack parameters
  $region = hiera('profile::region')
  $keystone_password = hiera('profile::glance::keystone::password')

  # Determine which address to use for the glance registry
  $management_if = hiera('profile::interfaces::management')
  $management_ip = hiera("profile::interfaces::${management_if}::address", undef)
  $adminlb_ip = hiera('profile::haproxy::management::ipv4', undef)

  # Determine where the keystone service is located.
  $keystone_public_ip = hiera('profile::api::keystone::public::ip', '127.0.0.1')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $admin_endpoint = hiera('profile::openstack::endpoint::admin', undef)
  $public_endpoint = hiera('profile::openstack::endpoint::public', undef)
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_public   = pick($public_endpoint, "http://${keystone_public_ip}")

  # Retrieve addresses for the memcached servers, either the old IP or the new
  # list of hosts.
  $memcached_ip = hiera('profile::memcache::ip', undef)
  $memcache_servers = hiera_array('profile::memcache::servers', undef)

  # Variables to determine if haproxy or keepalived should be configured.
  $glance_admin_ip = hiera('profile::api::glance::admin::ip', false)
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)

  require ::profile::openstack::repo
  contain ::profile::openstack::glance::ceph
  contain ::profile::openstack::glance::firewall::server::api
  include ::profile::openstack::glance::sudo
  include ::profile::openstack::glance::rabbit

  # If this server should be placed behind haproxy, export a haproxy
  # configuration snippet.
  if($confhaproxy) {
    contain ::profile::openstack::glance::haproxy::backend::server
  }

  # Only configure keepalived if we actually have a shared IP for glance. We
  # use this in the old controller-infrastructure. New infrastructures should be
  # based on haproxy instead.
  if($glance_admin_ip) {
    contain ::profile::openstack::glance::keepalived
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
    memcached_servers => pick($memcache_servers, $memcached_ip),
    region_name       => $region,
  }

  glance_api_config {
    'DEFAULT/default_store': value => 'rbd';
  }
}
