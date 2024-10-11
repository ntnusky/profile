# Configures the firewall for puppetmasters. We allow all our infra-networks
# contact these directly in addition to through the loadbalancers. 
class profile::services::puppet::server::firewall {
  ::profile::firewall::infra::all { 'puppetserver':
    port => 8140,
  }
  # Puppetservers need to ssh to each-other to sync hieradata
  ::profile::firewall::infra::all { 'puppetserver-ssh':
    port => 22,
  }
}
