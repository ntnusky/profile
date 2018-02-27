# Perfomes basic heat configuration
class profile::openstack::heat::base {
  # Retrieve service IP Addresses
  $keystone_admin_ip  = hiera('profile::api::keystone::admin::ip')

  # Retrieve api urls, if they exist. 
  $admin_endpoint    = hiera('profile::openstack::endpoint::admin', false)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', false)

  # Determine which endpoint to use
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")

  $region = hiera('profile::region')

  $memcached_ip = hiera('profile::memcache::ip')
  $mysql_pass = hiera('profile::mysql::heatpass')
  $mysql_ip = hiera('profile::mysql::ip')
  $database_connection = "mysql://heat:${mysql_pass}@${mysql_ip}/heat"

  require ::profile::openstack::repo

  class { '::heat':
    database_connection => $database_connection,
    region_name         => $region,
    rabbit_password     => $rabbit_pass,
    rabbit_userid       => $rabbit_user,
    rabbit_host         => $rabbit_ip,
    auth_uri            => "${keystone_internal}:5000/",
    identity_uri        => "${keystone_admin}:35357",
    keystone_tenant     => 'services',
    keystone_user       => 'heat',
    keystone_password   => $mysql_pass,
    memcached_servers   => $memcached_ip,
  }
}
