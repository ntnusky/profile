# This class configures firewall rules for apache port 80,443. The webservers
# are always behind loadbalancers; so we limit access to the region-specific
# infra-network.
class profile::services::apache::firewall {
  $common = lookup('profile::apache::interregional', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  if($common) {
    ::profile::firewall::infra::all { 'web':
      port => [ 80, 443 ],
    }
  } else {
    ::profile::firewall::infra::region { 'web':
      port => [ 80, 443 ],
    }
  }
}
