# Configures the haproxy in frontend for the puppetmasters 
class profile::services::puppet::server::haproxy::frontend {
  include ::profile::services::puppet::server::firewall

  ::profile::services::haproxy::frontend { 'puppetserver':
    profile => 'management',
    port    => 8140,
  }
}
