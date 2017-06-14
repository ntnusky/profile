# Creates the database for heat
class profile::openstack::heat::database {
  $mysql_pass = hiera('profile::mysql::heatpass')
  $allowed_hosts = hiera('profile::mysql::allowed_hosts')

  require ::profile::openstack::heat::base

  class { '::heat::db::mysql':
    user          => 'heat',
    password      => $mysql_pass,
    allowed_hosts => $allowed_hosts,
    dbname        => 'heat',
  }
}
