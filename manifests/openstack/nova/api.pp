# Installs and configures the nova API.
class profile::openstack::nova::api {
  $memcache_ip = hiera('profile::memcache::ip')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $nova_public_ip = hiera('profile::api::nova::public::ip')
  $nova_admin_ip = hiera('profile::api::nova::admin::ip')

  $nova_password = hiera('profile::nova::keystone::password')
  $nova_secret = hiera('profile::nova::sharedmetadataproxysecret')
  $sync_db = hiera('profile::nova::sync_db')
  $region = hiera('profile::region')

  require ::profile::openstack::repo
  require ::profile::openstack::nova::base
  require ::profile::openstack::nova::database
  contain ::profile::openstack::nova::keepalived
  contain ::profile::openstack::nova::placement
  include ::profile::openstack::nova::munin::api

  class { '::nova::keystone::auth':
    password        => $nova_password,
    public_url      => "http://${nova_public_ip}:8774/v2/%(tenant_id)s",
    internal_url    => "http://${nova_admin_ip}:8774/v2/%(tenant_id)s",
    admin_url       => "http://${nova_admin_ip}:8774/v2/%(tenant_id)s",
    public_url_v3   => "http://${nova_public_ip}:8774/v3",
    internal_url_v3 => "http://${nova_admin_ip}:8774/v3",
    admin_url_v3    => "http://${nova_admin_ip}:8774/v3",
    region          => $region,
  }

  class { '::nova::keystone::authtoken':
    auth_url          => "http://${keystone_admin_ip}:35357/",
    auth_uri          => "http://${keystone_public_ip}:5000/",
    password          => $nova_password,
    memcached_servers => $memcache_ip,
    region_name       => $region,
  }

  class { '::nova::api':
    api_bind_address                     => $nova_public_ip,
    neutron_metadata_proxy_shared_secret => $nova_secret,
    sync_db                              => $sync_db,
    sync_db_api                          => $sync_db,
    enabled                              => false,
    service_name                         => 'httpd',
  }

  # Warning: This class is deprecated in Ocata
  class { '::nova::wsgi::apache':
    servername => $nova_public_ip,
    ssl        => false,
  }

  nova_config {
    'cache/enabled':          value => true;
    'cache/backend':          value => 'oslo_cache.memcache_pool';
    'cache/memcache_servers': value => "${memcache_ip}:11211";
  }
}
