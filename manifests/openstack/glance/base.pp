# Base glance configuration
class profile::openstack::glance::base {
  $rabbit_ip = hiera('profile::rabbitmq::ip')
  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')

  require ::profile::openstack::repo
  include ::profile::openstack::glance::sudo

  class { '::glance::notify::rabbitmq':
    rabbit_password => $rabbit_pass,
    rabbit_userid   => $rabbit_user,
    rabbit_host     => $rabbit_ip,
  }
}
