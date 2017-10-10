# Configures the haproxy in frontend for the puppetmasters 
class profile::services::puppetmaster::loadbalancer {
  require ::profile::services::keepalived::haproxy::management
  contain ::profile::services::puppetmaster::haproxy::frontend
}
