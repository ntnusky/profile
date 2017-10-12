# Configures the haproxy in frontend for the puppetdb service 
class profile::services::puppet::db::haproxy::frontend {
  require ::profile::services::haproxy

  $ip = hiera('profile::haproxy::management::ip')

  haproxy::listen { 'puppetdb':
    ipaddress => $ip,
    ports     => '8081',
  }
}
