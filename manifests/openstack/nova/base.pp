# Performs basic nova configuration.
class profile::openstack::nova::base {
  # Determine correct mysql IP
  $mysql_password = hiera('profile::mysql::novapass')
  $mysql_old = hiera('profile::mysql::ip', undef)
  $mysql_new = hiera('profile::haproxy::management::ipv4', undef)
  $mysql_ip = pick($mysql_new, $mysql_old)
  
  # Mysql connectionstrings
  $db_con = "mysql://nova:${mysql_password}@${mysql_ip}/nova"
  $api_db_con = "mysql://nova_api:${mysql_password}@${mysql_ip}/nova_api"

  # RabbitMQ connection-information
  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')
  $rabbit_ip = hiera('profile::rabbitmq::ip')

  $internal_endpoint = hiera('profile::openstack::endpoint::internal', false)
  if($internal_endpoint) {
    $glance_internal = "${internal_endpoint}:9292"
  } else {
    $controller_management_addresses = hiera('controller::management::addresses')
    $oldapi = join([join($controller_management_addresses, ':9292,'),''], ':9292')
    $glance_internal = $oldapi
  }

  require ::profile::openstack::repo
  include ::profile::openstack::nova::sudo

  class { '::nova':
    database_connection     => $db_con,
    api_database_connection => $api_db_con,
    rabbit_host             => $rabbit_ip,
    rabbit_userid           => $rabbit_user,
    rabbit_password         => $rabbit_pass,
    image_service           => 'nova.image.glance.GlanceImageService',
    glance_api_servers      => $glance_internal,
  }
}
