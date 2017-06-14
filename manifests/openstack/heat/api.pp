# Installs the heat API
class profile::openstack::heat::api {
  $heat_admin_ip = hiera('profile::api::heat::admin::ip')
  $heat_public_ip = hiera('profile::api::heat::public::ip')

  $mysql_pass = hiera('profile::mysql::heatpass')
  $region = hiera('profile::region')

  require ::profile::openstack::repo
  require ::profile::openstack::heat::database
  require ::profile::openstack::heat::base
  require ::profile::openstack::heat::keepalived

  class  { '::heat::keystone::auth':
    password     => $mysql_pass,
    public_url   => "http://${heat_public_ip}:8004/v1/%(tenant_id)s",
    internal_url => "http://${heat_admin_ip}:8004/v1/%(tenant_id)s",
    admin_url    => "http://${heat_admin_ip}:8004/v1/%(tenant_id)s",
    region       => $region,
  }

  class { '::heat::keystone::auth_cfn':
    password     => $mysql_pass,
    service_name => 'heat-cfn',
    region       => $region,
    public_url   => "http://${heat_public_ip}:8000/v1",
    internal_url => "http://${heat_admin_ip}:8000/v1",
    admin_url    => "http://${heat_admin_ip}:8000/v1",
  }

  class { 'heat::api':
    bind_host => $heat_public_ip,
  }

  class { 'heat::api_cfn':
    bind_host => $heat_public_ip,
  }
}
