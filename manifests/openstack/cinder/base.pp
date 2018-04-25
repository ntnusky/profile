# Configures the base cinder config
class profile::openstack::cinder::base {
  # Determine where the database resides 
  $mysql_pass = hiera('profile::mysql::cinderpass')
  $mysql_old = hiera('profile::mysql::ip', undef)
  $mysql_new = hiera('profile::haproxy::management::ipv4', undef)
  $mysql_ip = pick($mysql_new, $mysql_old)
  $database_connection = "mysql://cinder:${mysql_pass}@${mysql_ip}/cinder"

  # Credentials for the messagequeue
  $rabbit_ip = hiera('profile::rabbitmq::ip')
  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')

  require ::profile::openstack::repo
  require ::profile::openstack::cinder::sudo

  class { '::cinder':
    database_connection => $database_connection,
    rabbit_host         => $rabbit_ip,
    rabbit_userid       => $rabbit_user,
    rabbit_password     => $rabbit_pass,
  }
}
