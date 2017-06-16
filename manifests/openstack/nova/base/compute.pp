# Basic nova configuration for compute nodes.
class profile::openstack::nova::base::compute {
  $database_connection = "mysql://nova:${mysql_password}@${mysql_ip}/nova"
  $controller_management_addresses = hiera('controller::management::addresses')

  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')
  $rabbit_ip = hiera('profile::rabbitmq::ip')

  require ::profile::openstack::repo
  include ::profile::openstack::nova::sudo

  class { '::nova':
    database_connection => $database_connection,
    glance_api_servers  =>
      join([join($controller_management_addresses, ':9292,'),''], ':9292'),
    rabbit_host         => $rabbit_ip,
    rabbit_userid       => $rabbit_user,
    rabbit_password     => $rabbit_pass,
  }
}
