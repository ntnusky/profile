# This class configures firewall rules for apache port 80,443. The webservers
# are always behind loadbalancers; so we limit access to the region-specific
# infra-network.
class profile::services::apache::firewall {
  ::profile::firewall::infra::region { 'web':
    port => [ 80, 443 ],
  }
}
