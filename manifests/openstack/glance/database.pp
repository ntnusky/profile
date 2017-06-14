# This class sets up the database for glance
class profile::openstack::glance::database {
  $password = hiera('profile::mysql::glancepass')
  $allowed_hosts = hiera('profile::mysql::allowed_hosts')

  require ::profile::openstack::repo

  class { '::glance::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
