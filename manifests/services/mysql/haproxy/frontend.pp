# Configures the haproxy in frontend for the mysql cluster 
class profile::services::mysql::haproxy::frontend {
  require ::profile::services::haproxy

  $ip = hiera('profile::haproxy::management::ip')

  haproxy::listen { 'mysqlcluster':
    ipaddress => $ip,
    ports     => '3306',
  }
}
