# Creates the databases for nova.
class profile::openstack::nova::database {
  $mysql_password = hiera('profile::mysql::novapass')
  $allowed_hosts = hiera('profile::mysql::allowed_hosts')

  class { 'nova::db::mysql' :
    password      => $mysql_password,
    allowed_hosts => $allowed_hosts,
  }

  class { 'nova::db::mysql_api' :
    password      => $mysql_password,
    allowed_hosts => $allowed_hosts,
  }
}
