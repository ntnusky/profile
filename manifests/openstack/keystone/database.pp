# Creates the database for keystone
class profile::openstack::keystone::database {
  $password = hiera('profile::mysql::keystonepass')
  $allowed_hosts = hiera('profile::mysql::allowed_hosts')

  require ::profile::openstack::repo

  class { '::keystone::db::mysql':
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
