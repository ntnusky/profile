# Installs and configures puppetdb 
class profile::services::puppet::db {
  include ::profile::services::puppet::altnames
  include ::profile::services::puppet::db::firewall
  include ::profile::services::puppet::db::haproxy::backend

  $dbhost = hiera('profile::postgres::ipv4')
  $dbport = hiera('profile::postgres::port', '5432')
  $dbname = hiera('profile::puppetdb::database::name')
  $dbuser = hiera('profile::puppetdb::database::user')
  $dbpass = hiera('profile::puppetdb::database::pass')

  $if = hiera('profile::interfaces::management')
  $autoip = $::facts['networking']['interfaces'][$if]['ip']
  $ip = hiera("profile::interfaces::${if}::address", $autoip)

  class { '::puppetdb::server':
    database           => 'postgres',
    database_port      => $dbport,
    database_host      => $dbhost,
    database_username  => $dbuser,
    database_password  => $dbpass,
    database_name      => $dbname,
    ssl_listen_address => $ip,
  }
}
