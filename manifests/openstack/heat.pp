# Installs and configures the heat service on an openstack controller node in
# the SkyHiGh architecture
class profile::openstack::heat {
  $password = hiera('profile::mysql::heatpass')
  $allowed_hosts = hiera('profile::mysql::allowed_hosts')
  $mysql_ip = hiera('profile::mysql::ip')
  $rabbit_ip = hiera('profile::rabbitmq::ip')
  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')
  $keystone_ip = hiera('profile::api::keystone::public::ip')
  $keystone_ip_admin = hiera('profile::api::keystone::admin::ip')
  $memcached_ip = hiera('profile::memcache::ip')
  $auth_encryption_key = hiera('profile::heat::auth_encryption_key')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $region = hiera('profile::region')
  $admin_ip = hiera('profile::api::heat::admin::ip')
  $public_ip = hiera('profile::api::heat::public::ip')
  $vrid = hiera('profile::api::heat::vrrp::id')
  $vrpri = hiera('profile::api::heat::vrrp::priority')
  $public_if = hiera('profile::interfaces::public')
  $management_if = hiera('profile::interfaces::management')
  $database_connection = "mysql://heat:${password}@${mysql_ip}/heat"

  require ::profile::services::rabbitmq
  require ::profile::mysql::cluster
  require ::profile::services::keepalived
  require ::profile::openstack::repo

  anchor { 'profile::openstack::heat::begin' : } ->

  class { '::heat::db::mysql':
    user          => 'heat',
    password      => $password,
    allowed_hosts => $allowed_hosts,
    dbname        => 'heat',
  } ->

  class  { '::heat::keystone::auth':
    password     => $password,
    public_url   => "http://${public_ip}:8004/v1/%(tenant_id)s",
    internal_url => "http://${admin_ip}:8004/v1/%(tenant_id)s",
    admin_url    => "http://${admin_ip}:8004/v1/%(tenant_id)s",
    region       => $region,
  }

  class { '::heat::keystone::auth_cfn':
    password     => $password,
    service_name => 'heat-cfn',
    region       => $region,
    public_url   => "http://${public_ip}:8000/v1",
    internal_url => "http://${admin_ip}:8000/v1",
    admin_url    => "http://${admin_ip}:8000/v1",
  }

  class { '::heat::keystone::authtoken':
    auth_url          => "http://${keystone_ip_admin}:35357/",
    auth_uri          => "http://${keystone_ip}:5000/",
    memcached_servers => $memcached_ip,
    region_name       => $region,
  } ->

  class { '::heat':
    database_connection => $database_connection,
    region_name         => $region, # probably uncomment this when Kilo
    rabbit_password     => $rabbit_pass,
    rabbit_userid       => $rabbit_user,
    rabbit_host         => $rabbit_ip,
    auth_strategy       => '',
    #auth_uri           => "http://${keystone_ip}:5000/v2.0",
    #identity_uri       => "http://${keystone_ip_admin}:35357",
    #keystone_tenant    => 'services',
    #keystone_user      => 'heat',
    #keystone_password  => $password,
  }

  class { 'heat::engine':
    auth_encryption_key           => $auth_encryption_key,
    heat_metadata_server_url      => "http://${public_ip}:8000",
    heat_waitcondition_server_url =>
      "http://${public_ip}:8000/v1/waitcondition",
  }

  class { 'heat::api':
    bind_host => $public_ip,
  }

  class { 'heat::api_cfn':
    bind_host => $public_ip,
  }

  keepalived::vrrp::script { 'check_heat':
    script => '/usr/bin/killall -0 heat-api',
  } ->

  keepalived::vrrp::instance { 'admin-heat':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${admin_ip}/32",
    ],
    track_script      => 'check_heat',
  } ->

  keepalived::vrrp::instance { 'public-heat':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${public_ip}/32",
    ],
    track_script      => 'check_heat',
  } ->

  anchor { 'profile::openstack::heat::end' : }
}
