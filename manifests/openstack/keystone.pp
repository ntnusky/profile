class profile::openstack::keystone {
  $password = hiera("profile::mysql::keystonepass")
  $allowed_hosts = hiera("profile::mysql::allowed_hosts")
  $mysql_ip = hiera("profile::mysql::ip")

  $region = hiera("profile::region")
  $admin_ip = hiera("profile::api::admin::ip")
  $public_ip = hiera("profile::api::public::ip")
  
  $admin_token = hiera("profile::keystone::admin_token")
  $admin_email = hiera("profile::keystone::admin_email")
  $admin_pass = hiera("profile::keystone::admin_password")

  $database_connection = "mysql://keystone:${password}@${mysql_ip}/keystone"
  
  include ::profile::openstack::repo
  
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
  
  anchor { "profile::openstack::keystone::end" : }
}
