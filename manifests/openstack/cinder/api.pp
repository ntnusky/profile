# Installs and configures the cinder API
class profile::openstack::cinder::api {
  $region = hiera('profile::region')

  $keystone_password = hiera('profile::cinder::keystone::password')

  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $cinder_public_ip = hiera('profile::api::cinder::public::ip')
  $cinder_admin_ip = hiera('profile::api::cinder::admin::ip')
  $memcached_ip = hiera('profile::memcache::ip')

  $admin_endpoint = hiera('profile::openstack::endpoint::admin', false)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', false)
  $public_endpoint = hiera('profile::openstack::endpoint::public', false)

  require ::profile::baseconfig::firewall
  require ::profile::openstack::repo
  require ::profile::openstack::cinder::base
  require ::profile::openstack::cinder::database
  contain ::profile::openstack::cinder::firewall::server
  contain ::profile::openstack::cinder::keepalived

  if($confhaproxy) {
    contain ::profile::openstack::cinder::haproxy::backend::server
  }

  $cinder_admin    = pick($admin_endpoint, "http://${cinder_admin_ip}")
  $cinder_internal = pick($internal_endpoint, "http://${cinder_admin_ip}")
  $cinder_public   = pick($public_endpoint, "http://${cinder_public_ip}")
  $keystone_admin  = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_public = pick($public_endpoint, "http://${keystone_public_ip}")

  class  { '::cinder::keystone::auth':
    password        => $keystone_password,
    public_url      => "${cinder_public}:8776/v1/%(tenant_id)s",
    internal_url    => "${cinder_internal}:8776/v1/%(tenant_id)s",
    admin_url       => "${cinder_admin}:8776/v1/%(tenant_id)s",
    public_url_v2   => "${cinder_public}:8776/v2/%(tenant_id)s",
    internal_url_v2 => "${cinder_internal}:8776/v2/%(tenant_id)s",
    admin_url_v2    => "${cinder_admin}:8776/v2/%(tenant_id)s",
    public_url_v3   => "${cinder_public}:8776/v3/%(tenant_id)s",
    internal_url_v3 => "${cinder_internal}:8776/v3/%(tenant_id)s",
    admin_url_v3    => "${cinder_admin}:8776/v3/%(tenant_id)s",
    region          => $region,
  }

  class { '::cinder::keystone::authtoken':
    auth_url          => "${keystone_admin}:35357",
    auth_uri          => "${keystone_public}:5000",
    password          => $keystone_password,
    memcached_servers => $memcached_ip,
    region_name       => $region,
  }

  class { '::cinder::api':
    keystone_enabled    => false,
    auth_strategy       => '',
    enabled             => true,
    default_volume_type => 'Normal',
  }
}
