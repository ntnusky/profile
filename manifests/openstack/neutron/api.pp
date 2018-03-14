# Installs and configures the neutron api
class profile::openstack::neutron::api {
  # Database and cache
  $mysql_password = hiera('profile::mysql::neutronpass')
  $mysql_ip = hiera('profile::mysql::ip')
  $memcached_ip = hiera('profile::memcache::ip')

  # Retrieve service IP Addresses
  $keystone_admin_ip  = hiera('profile::api::keystone::admin::ip')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $nova_admin_ip      = hiera('profile::api::nova::admin::ip')
  $neutron_admin_ip   = hiera('profile::api::neutron::admin::ip')
  $neutron_public_ip  = hiera('profile::api::neutron::public::ip')

  # Retrieve api urls, if they exist. 
  $admin_endpoint    = hiera('profile::openstack::endpoint::admin', undef)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', undef)
  $public_endpoint   = hiera('profile::openstack::endpoint::public', undef)

  # Determine which endpoint to use
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")
  $nova_internal     = pick($internal_endpoint, "http://${nova_admin_ip}")
  $neutron_admin     = pick($admin_endpoint, "http://${neutron_admin_ip}")
  $neutron_internal  = pick($internal_endpoint, "http://${neutron_admin_ip}")
  $neutron_public    = pick($public_endpoint, "http://${neutron_public_ip}")

  # Openstack settings
  $nova_password = hiera('profile::nova::keystone::password')
  $neutron_password = hiera('profile::neutron::keystone::password')
  $service_providers = hiera('profile::neutron::service_providers')
  $region = hiera('profile::region')

  # Database connection string
  $database_connection = "mysql://neutron:${mysql_password}@${mysql_ip}/neutron"

  require ::profile::openstack::neutron::base
  contain ::profile::openstack::neutron::database
  contain ::profile::openstack::neutron::firewall::l3agent
  contain ::profile::openstack::neutron::keepalived

  # Configure the neutron API endpoint in keystone
  class { '::neutron::keystone::auth':
    password     => $neutron_password,
    public_url   => "${neutron_public}:9696",
    internal_url => "${neutron_internal}:9696",
    admin_url    => "${neutron_admin}:9696",
    region       => $region,
  }

  # Configure the service user neutron uses
  class { '::neutron::keystone::authtoken':
    password          => $neutron_password,
    auth_url          => "${keystone_admin}:35357/",
    auth_uri          => "${keystone_internal}:5000/",
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
    auth_url    => "${keystone_admin}:35357",
    region_name => $region,
    nova_url    => "${nova_internal}:8774/v2",
  }
}
