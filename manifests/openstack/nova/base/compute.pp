# Basic nova configuration for compute nodes.
class profile::openstack::nova::base::compute {
  # Determine correct mysql settings
  $mysql_password = hiera('profile::mysql::novapass')
  $mysql_old = hiera('profile::mysql::ip', undef)
  $mysql_new = hiera('profile::haproxy::management::ipv4', undef)
  $mysql_ip = pick($mysql_new, $mysql_old)
  $database_connection = "mysql://nova:${mysql_password}@${mysql_ip}/nova"

  $internal_endpoint = hiera('profile::openstack::endpoint::internal', undef)
  if($internal_endpoint) {
    $glance_internal = "${internal_endpoint}:9292"
  } else {
    $controller_management_addresses = hiera('controller::management::addresses')
    $oldapi = join([join($controller_management_addresses, ':9292,'),''], ':9292')
    $glance_internal = $oldapi
  }

  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $keystone_endpoint = pick($internal_endpoint, "http://${keystone_admin_ip}")

  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')
  $rabbit_ip = hiera('profile::rabbitmq::ip')

  $placement_password = hiera('profile::placement::keystone::password')
  $region = hiera('profile::region')

  require ::profile::openstack::repo
  include ::profile::openstack::nova::sudo

  class { '::nova':
    database_connection           => $database_connection,
    glance_api_servers            => $glance_internal,
    rabbit_host                   => $rabbit_ip,
    rabbit_userid                 => $rabbit_user,
    rabbit_password               => $rabbit_pass,
    block_device_allocate_retries => 120,
  }

  class { '::nova::placement':
    password       => $placement_password,
    auth_url       => "${keystone_endpoint}:35357/v3",
    os_region_name => $region,
  }
}
