# Basic nova configuration for compute nodes.
class profile::openstack::nova::base::compute {
  $mysql_password = hiera('profile::mysql::novapass')
  $mysql_ip = hiera('profile::mysql::ip')
  $database_connection = "mysql://nova:${mysql_password}@${mysql_ip}/nova"
  $controller_management_addresses = hiera('controller::management::addresses')

  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')
  $rabbit_ip = hiera('profile::rabbitmq::ip')

  $placement_password = hiera('profile::placement::keystone::password')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $region = hiera('profile::region')

  require ::profile::openstack::repo
  include ::profile::openstack::nova::sudo

  class { '::nova':
    database_connection              => $database_connection,
    glance_api_servers               =>
      join([join($controller_management_addresses, ':9292,'),''], ':9292'),
    rabbit_host                      => $rabbit_ip,
    rabbit_userid                    => $rabbit_user,
    rabbit_password                  => $rabbit_pass,
    block_device_allocate_retries    => 120,
    resume_guests_state_on_host_boot => true,
  }
  class { '::nova::placement':
    password       => $placement_password,
    auth_url       => "http://${keystone_admin_ip}:35357/v3",
    os_region_name => $region,
  }
}
