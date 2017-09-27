# Installs and configures puppetdb 
class profile::services::puppetdb::server {
  contain ::profile::services::puppetdb::keepalived 

  $dbhost = hiera('profile::postgres::ip')
  $dbport = hiera('profile::postgres::port', '5432')
  $dbname = hiera('profile::puppetdb::database::name')
  $dbuser = hiera('profile::puppetdb::database::user')
  $dbpass = hiera('profile::puppetdb::database::pass')

  class { 'puppetdb::server':
    database          => 'postgres',
    database_port     => $dbport,
    database_host     => $dbhost,
    database_username => $dbuser,
    database_password => $dbpass,
    database_name     => $dbname,
  }
}
