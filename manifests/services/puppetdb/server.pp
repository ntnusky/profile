# Installs and configures puppetdb 
class profile::services::puppetdb::server {
  $dbhost = hiera('profile::postgres::ip')
  $dbport = hiera('profile::postgres::port', '5432')
  $dbname = hiera('profile::puppetdb::database::name')
  $dbuser = hiera('profile::puppetdb::database::user')
  $dbpass = hiera('profile::puppetdb::database::pass')

  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  class { 'puppetdb::server':
    database           => 'postgres',
    database_port      => $dbport,
    database_host      => $dbhost,
    database_username  => $dbuser,
    database_password  => $dbpass,
    database_name      => $dbname,
    ssl_listen_address => $ip,
  }
}
