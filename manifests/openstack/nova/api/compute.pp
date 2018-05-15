# Installs and configures the nova compute API.
class profile::openstack::nova::api::compute {
  # Retrieve addresses for the memcached servers, either the old IP or the new
  # list of hosts.
  $memcached_ip = hiera('profile::memcache::ip', undef)
  $memcache_servers = hiera_array('profile::memcache::servers', undef)
  $memcache_servers_real = pick($memcache_servers, [$memcached_ip])
  $memcache = $memcache_servers_real.map | $server | {
    "${server}:11211"
  }

  # Determine if haproxy or keepalived should be configured
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)
  $nova_admin_ip = hiera('profile::api::nova::admin::ip', false)

  # Retrieve openstack parameters
  $nova_password = hiera('profile::nova::keystone::password')
  $nova_secret = hiera('profile::nova::sharedmetadataproxysecret')
  $sync_db = hiera('profile::nova::sync_db')
  $region = hiera('profile::region')

  # Determine the keystone endpoint.
  $admin_endpoint = hiera('profile::openstack::endpoint::admin', undef)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', undef)
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")

  require ::profile::openstack::repo
  require ::profile::openstack::nova::base
  contain ::profile::openstack::nova::firewall::server
  include ::profile::openstack::nova::munin::api

  if($confhaproxy) {
    contain ::profile::openstack::glance::haproxy::backend::api
  }

  if($nova_admin_ip) {
    contain ::profile::openstack::nova::keepalived
  }

  class { '::nova::keystone::authtoken':
    auth_url          => "${keystone_admin}:35357/",
    auth_uri          => "${keystone_internal}:5000/",
    password          => $nova_password,
    memcached_servers => $memcache,
    region_name       => $region,
  }

  class { '::nova::api':
    neutron_metadata_proxy_shared_secret => $nova_secret,
    enable_proxy_headers_parsing         => $confhaproxy,
    sync_db                              => $sync_db,
    sync_db_api                          => $sync_db,
  }

  nova_config {
    'cache/enabled':          value => true;
    'cache/backend':          value => 'oslo_cache.memcache_pool';
    'cache/memcache_servers': value => $memcache;
  }
}
