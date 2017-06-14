# Perfomes basic heat configuration
class profile::openstack::heat::base {
  $rabbit_ip = hiera('profile::rabbitmq::ip')
  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')

  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')

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
    auth_uri            => "http://${keystone_public_ip}:5000/",
    identity_uri        => "http://${keystone_admin_ip}:35357",
    keystone_tenant     => 'services',
    keystone_user       => 'heat',
    keystone_password   => $mysql_pass,
    memcached_servers   => $memcached_ip,
  }
}
