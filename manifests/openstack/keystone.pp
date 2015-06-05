class profile::openstack::keystone {
  $password = hiera("profile::mysql::keystonepass")
  $allowed_hosts = hiera("profile::mysql::allowed_hosts")
  $mysql_ip = hiera("profile::mysql::ip")
  $vrrp_password 	= hiera("profile::keepalived::vrrp_password")

  $region = hiera("profile::region")
  $admin_ip = hiera("profile::api::keystone::admin::ip")
  $public_ip = hiera("profile::api::keystone::public::ip")
  $vrid = hiera("profile::api::keystone::vrrp::id")
  $vrpri = hiera("profile::api::keystone::vrrp::priority")
  
  $admin_token = hiera("profile::keystone::admin_token")
  $admin_email = hiera("profile::keystone::admin_email")
  $admin_pass = hiera("profile::keystone::admin_password")

  $public_if = hiera("profile::interface::public")
  $management_if = hiera("profile::interface::management")

  $database_connection = "mysql://keystone:${password}@${mysql_ip}/keystone"
  
  include ::profile::openstack::repo
 
  Anchor["profile::keepalived::end"] ->

  anchor { "profile::openstack::keystone::begin" : } ->

  class { "::keystone::db::mysql":
    user          => 'keystone',
    password      => $password,
    allowed_hosts => $allowed_hosts,
    dbname        => 'keystone',
    require       => Anchor['profile::mysqlcluster::end'],
  } ->

  class { '::keystone':
    admin_token         => $admin_token,
    database_connection => $database_connection,
    verbose             => $verbose,
    debug               => $debug,
    enabled             => true,
    admin_bind_host     => "0.0.0.0",
  } ->
   
  class { '::keystone::roles::admin':
    email        => $admin_email,
    password     => $admin_pass,
    admin_tenant => 'admin',
  } ->
  
  class { 'keystone::endpoint':
    public_url   => "http://${public_ip}:5000",
    admin_url    => "http://${admin_ip}:35357",
    internal_url => "http://${admin_ip}:5000",
    region       => $region,
  } ->
  
  keepalived::vrrp::script { 'check_keystone':
    script => '/usr/bin/killall -0 keystone-all',
  } ->

  keepalived::vrrp::instance { 'admin-keystone':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${admin_ip}/32",	
    ],
    track_script      => 'check_keystone',
  } ->

  keepalived::vrrp::instance { 'public-keystone':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${public_ip}/32",	
    ],
    track_script      => 'check_keystone',
  } ->
  
  anchor { "profile::openstack::keystone::end" : }
}
