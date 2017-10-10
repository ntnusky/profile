# Configures the haproxy in frontend for the puppetmasters 
class profile::services::puppetmaster::haproxy {
  require ::profile::services::haproxy

  $ip = hiera('profile::haproxy::management::ip')

  haproxy::listen { 'puppetserver':
    ipaddress => $ip,
    ports     => '8140',
  }
}
