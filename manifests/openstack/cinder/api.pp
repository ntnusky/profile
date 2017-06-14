# Installs and configures the cinder API
class profile::openstack::cinder::api {
  $region = hiera('profile::region')

  $keystone_password = hiera('profile::cinder::keystone::password')

  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $cinder_public_ip = hiera('profile::api::cinder::public::ip')
  $cinder_admin_ip = hiera('profile::api::cinder::admin::ip')
  $memcached_ip = hiera('profile::memcache::ip')

  require ::profile::openstack::repo

  class  { '::cinder::keystone::auth':
    password        => $keystone_password,
    public_url      => "http://${cinder_public_ip}:8776/v1/%(tenant_id)s",
    internal_url    => "http://${cinder_admin_ip}:8776/v1/%(tenant_id)s",
    admin_url       => "http://${cinder_admin_ip}:8776/v1/%(tenant_id)s",
    public_url_v2   => "http://${cinder_public_ip}:8776/v2/%(tenant_id)s",
    internal_url_v2 => "http://${cinder_admin_ip}:8776/v2/%(tenant_id)s",
    admin_url_v2    => "http://${cinder_admin_ip}:8776/v2/%(tenant_id)s",
    public_url_v3   => "http://${cinder_public_ip}:8776/v3/%(tenant_id)s",
    internal_url_v3 => "http://${cinder_admin_ip}:8776/v3/%(tenant_id)s",
    admin_url_v3    => "http://${cinder_admin_ip}:8776/v3/%(tenant_id)s",
    region          => $region,
  }

  class { '::cinder::keystone::authtoken':
    auth_url          => "http://${keystone_admin_ip}:35357",
    auth_uri          => "http://${keystone_public_ip}:5000",
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
