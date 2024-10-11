# Configures the firewall for puppetmasters. We allow all our infra-networks
# contact these directly in addition to through the loadbalancers. 
class profile::services::puppet::server::firewall {
  ::profile::firewall::infra::all { 'puppetserver':
    port => 8140,
  }
}
