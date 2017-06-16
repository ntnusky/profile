# Creates the database for keystone
class profile::openstack::keystone::database {
  $password = hiera('profile::mysql::keystonepass')
  $allowed_hosts = hiera('profile::mysql::allowed_hosts')
  $mysql_ip = hiera('profile::mysql::ip')

  require ::profile::mysql::cluster
  require ::profile::openstack::repo

  class { '::keystone::db::mysql':
    user          => 'keystone',
    password      => $password,
    host          => $mysql_ip,
    allowed_hosts => $allowed_hosts,
    dbname        => 'keystone',
  }
}
