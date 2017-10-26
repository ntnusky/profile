# Configures the haproxy in frontend for the puppetdb service 
class profile::services::puppet::db::haproxy::frontend {
  require ::profile::services::haproxy
  include ::profile::services::puppet::db::firewall

  $ip = hiera('profile::haproxy::management::ip')

  haproxy::listen { 'puppetdb':
    ipaddress => $ip,
    ports     => '8081',
  }
}
