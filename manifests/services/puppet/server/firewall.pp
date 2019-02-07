# Configures the firewall for puppetmasters. 
class profile::services::puppet::server::firewall {
  ::profile::baseconfig::firewall::service::infra { 'Puppetmaster':
    protocol => 'tcp',
    port     => 8140,
  }
}
