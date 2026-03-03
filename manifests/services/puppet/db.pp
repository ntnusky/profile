# Installs and configures puppetdb 
class profile::services::puppet::db {
  include ::profile::baseconfig::puppet
  include ::profile::services::puppet::db::firewall
  include ::profile::services::puppet::db::haproxy::backend
  include ::profile::services::puppet::db::logging

  $dbhost = lookup('profile::postgres::ipv4', Stdlib::IP::Address::V4)
  $dbname = lookup('profile::puppetdb::database::name', String)
  $dbuser = lookup('profile::puppetdb::database::user', String)
  $dbpass = lookup('profile::puppetdb::database::pass', String)
  $dbport = lookup('profile::postgres::port', {
    'value_type'    => Stdlib::Port,
    'default_value' => 5432,
  })

  # TODO: Stop looking for the management-IP in hiera, and simply just take it
  # from SL.
  if($::sl2) {
    $default = $::sl2['server']['primary_interface']['name']
  } else {
    $default = undef
  }
  $if = lookup('profile::interfaces::management', {
    'default_value' => $default, 
    'value_type'    => String,
  })
  $autoip = $::facts['networking']['interfaces'][$if]['ip']
  $ip = lookup("profile::baseconfig::network::interfaces.${if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $autoip,
  })


  class { '::puppetdb::server':
    database_port          => $dbport,
    database_host          => $dbhost,
    database_username      => $dbuser,
    database_password      => $dbpass,
    database_name          => $dbname,
    read_database_username => $dbuser,
    read_database_password => $dbpass,
    ssl_listen_address     => $ip,
  }
}
