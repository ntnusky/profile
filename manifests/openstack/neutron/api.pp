# Installs and configures the neutron api
class profile::openstack::neutron::api {
  # Database and cache
  $mysql_password = hiera('profile::mysql::neutronpass')
  $mysql_ip = hiera('profile::mysql::ip')
  $memcached_ip = hiera('profile::memcache::ip')

  # IP Addresses
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $nova_public_ip = hiera('profile::api::nova::public::ip')
  $neutron_admin_ip = hiera('profile::api::neutron::admin::ip')
  $neutron_public_ip = hiera('profile::api::neutron::public::ip')

  # Openstack settings
  $nova_password = hiera('profile::nova::keystone::password')
  $neutron_password = hiera('profile::neutron::keystone::password')
  $service_providers = hiera('profile::neutron::service_providers')
  $region = hiera('profile::region')

  # Database connection string
  $database_connection = "mysql://neutron:${mysql_password}@${mysql_ip}/neutron"

  # Configure the neutron API endpoint in keystone
  class { '::neutron::keystone::auth':
    password     => $neutron_password,
    public_url   => "http://${neutron_public_ip}:9696",
    internal_url => "http://${neutron_admin_ip}:9696",
    admin_url    => "http://${neutron_admin_ip}:9696",
    region       => $region,
  }

  # Configure the service user neutron uses
  class { '::neutron::keystone::authtoken':
    password          => $neutron_password,
    auth_url          => "http://${keystone_admin_ip}:35357/",
    auth_uri          => "http://${keystone_public_ip}:5000/",
    memcached_servers => $memcached_ip,
    region_name       => $region,
  }

  # Install the neutron api
  class { '::neutron::server':
    database_connection              => $database_connection,
    sync_db                          => true,
    allow_automatic_l3agent_failover => true,
    service_providers                => $service_providers,
  }

  # Configure nova notifications system
  class { '::neutron::server::notifications':
    password    => $nova_password,
    auth_url    => "http://${keystone_admin_ip}:35357",
    region_name => $region,
    nova_url    => "http://${nova_public_ip}:8774/v2",
  }
}
