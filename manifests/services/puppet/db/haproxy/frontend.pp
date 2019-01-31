# Configures the haproxy in frontend for the puppetdb service
class profile::services::puppet::db::haproxy::frontend {
  include ::profile::services::puppet::db::firewall

  ::profile::services::haproxy::frontend { 'puppetserver':
    profile => 'management',
    port    => 8140,
  }
}
