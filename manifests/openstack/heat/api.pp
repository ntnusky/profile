# Installs the heat API
class profile::openstack::heat::api {
  # Retrieve service IP Addresses
  $heat_admin_ip = hiera('profile::api::heat::admin::ip')
  $heat_public_ip = hiera('profile::api::heat::public::ip')

  # Retrieve api urls, if they exist. 
  $admin_endpoint    = hiera('profile::openstack::endpoint::admin', undef)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', undef)
  $public_endpoint   = hiera('profile::openstack::endpoint::public', undef)

  # Determine which endpoint to use
  $heat_admin     = pick($admin_endpoint, "http://${heat_admin_ip}")
  $heat_internal  = pick($internal_endpoint, "http://${heat_admin_ip}")
  $heat_public    = pick($public_endpoint, "http://${heat_public_ip}")

  # Other settings
  $mysql_pass = hiera('profile::mysql::heatpass')
  $region = hiera('profile::region')

  require ::profile::openstack::heat::database
  require ::profile::openstack::heat::base
  contain ::profile::openstack::heat::keepalived
  require ::profile::openstack::repo

  class  { '::heat::keystone::auth':
    password     => $mysql_pass,
    public_url   => "${heat_public}:8004/v1/%(tenant_id)s",
    internal_url => "${heat_internal}:8004/v1/%(tenant_id)s",
    admin_url    => "${heat_admin}:8004/v1/%(tenant_id)s",
    region       => $region,
  }

  class { '::heat::keystone::auth_cfn':
    password     => $mysql_pass,
    service_name => 'heat-cfn',
    region       => $region,
    public_url   => "${heat_public}:8000/v1",
    internal_url => "${heat_internal}:8000/v1",
    admin_url    => "${heat_admin}:8000/v1",
  }

  class { '::heat::api':
  }

  class { '::heat::api_cfn':
  }
}
