# Installs and configures the cinder API
class profile::openstack::cinder::api {
  $region = hiera('profile::region')
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)

  $keystone_password = hiera('profile::cinder::keystone::password')

  # Determine the keystone endpoint
  $admin_endpoint = hiera('profile::openstack::endpoint::admin', undef)
  $public_endpoint = hiera('profile::openstack::endpoint::public', undef)
  $keystone_public_ip = hiera('profile::api::keystone::public::ip', false)
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', false)
  $keystone_admin  = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_public = pick($public_endpoint, "http://${keystone_public_ip}")

  # Retrieve addresses for the memcached servers, either the old IP or the new
  # list of hosts.
  $memcached_ip = hiera('profile::memcache::ip', undef)
  $memcache_servers = hiera_array('profile::memcache::servers', undef)

  require ::profile::openstack::repo
  require ::profile::openstack::cinder::base
  contain ::profile::openstack::cinder::firewall::server

  if($keystone_admin_ip) {
    contain ::profile::openstack::cinder::keepalived
  }

  if($confhaproxy) {
    contain ::profile::openstack::cinder::haproxy::backend::server
  }

  class { '::cinder::api':
    # Auth_strategy is blank to prevent cinder::api from including
    # ::cinder::keystone::authtoken.
    auth_strategy       => '',
    enabled             => true,
    default_volume_type => 'Normal',
    keystone_password   => $keystone_password,
  }

  class { '::cinder::keystone::authtoken':
    auth_url          => "${keystone_admin}:35357",
    auth_uri          => "${keystone_public}:5000",
    password          => $keystone_password,
    memcached_servers => pick($memcache_servers, $memcached_ip),
    region_name       => $region,
  }
}
