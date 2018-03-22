# Installs and configures the nova API.
class profile::openstack::nova::api {
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)
  $memcache_ip = hiera('profile::memcache::ip')
  $nova_public_ip = hiera('profile::api::nova::public::ip')
  $nova_admin_ip = hiera('profile::api::nova::admin::ip')

  $nova_password = hiera('profile::nova::keystone::password')
  $nova_secret = hiera('profile::nova::sharedmetadataproxysecret')
  $sync_db = hiera('profile::nova::sync_db')
  $region = hiera('profile::region')

  # Determine the keystone endpoint.
  $admin_endpoint = hiera('profile::openstack::endpoint::admin', undef)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', undef)
  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")

  require ::profile::openstack::repo
  require ::profile::openstack::nova::base
  require ::profile::openstack::nova::database
  require ::profile::openstack::nova::endpoint::api
  contain ::profile::openstack::nova::firewall::server
  contain ::profile::openstack::nova::keepalived
  contain ::profile::openstack::nova::placement
  include ::profile::openstack::nova::munin::api

  if($confhaproxy) {
    contain ::profile::openstack::glance::haproxy::backend::api
  }

  class { '::nova::keystone::authtoken':
    auth_url          => "${keystone_admin}:35357/",
    auth_uri          => "${keystone_internal}:5000/",
    password          => $nova_password,
    memcached_servers => $memcache_ip,
    region_name       => $region,
  }

  class { '::nova::api':
    neutron_metadata_proxy_shared_secret => $nova_secret,
    sync_db                              => $sync_db,
    sync_db_api                          => $sync_db,
  }

  nova_config {
    'cache/enabled':          value => true;
    'cache/backend':          value => 'oslo_cache.memcache_pool';
    'cache/memcache_servers': value => "${memcache_ip}:11211";
  }
}
