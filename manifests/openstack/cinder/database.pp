# Sets up the cinder database, and lets cinder populate it 
class profile::openstack::cinder::database {
  $password = hiera('profile::mysql::cinderpass')
  $allowed_hosts = hiera('profile::mysql::allowed_hosts')

  require ::profile::openstack::repo

  class { '::cinder::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
