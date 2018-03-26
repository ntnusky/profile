# Performs basic nova configuration.
class profile::openstack::nova::base {
  $mysql_password = hiera('profile::mysql::novapass')
  $mysql_ip = hiera('profile::mysql::ip')
  $db_con = "mysql://nova:${mysql_password}@${mysql_ip}/nova"
  $api_db_con = "mysql://nova_api:${mysql_password}@${mysql_ip}/nova_api"

  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')
  $rabbit_ip = hiera('profile::rabbitmq::ip')

  $controller_management_addresses = hiera('controller::management::addresses')
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', false)
  if($internal_endpoint) {
    $glance_internal = "${internal_endpoint}:9292"
  } else {
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
