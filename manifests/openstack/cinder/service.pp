# Installs and configures cinder services.
class profile::openstack::cinder::service {
  $mysql_pass = hiera('profile::mysql::cinderpass')
  $mysql_ip = hiera('profile::mysql::ip')
  $database_connection = "mysql://cinder:${mysql_pass}@${mysql_ip}/cinder"

  $rabbit_ip = hiera('profile::rabbitmq::ip')
  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')

  require ::profile::services::rabbitmq
  require ::profile::openstack::repo

  class { '::cinder':
    database_connection => $database_connection,
    rabbit_host         => $rabbit_ip,
    rabbit_userid       => $rabbit_user,
    rabbit_password     => $rabbit_pass,
  }

  class { '::cinder::scheduler':
    enabled          => true,
  }

  class { '::cinder::volume': }
}
