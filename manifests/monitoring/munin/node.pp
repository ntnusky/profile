# Defines a generic munin node
class profile::monitoring::munin::node {
  $management_ipv4 = hiera('profile::networks::management::ipv4::prefix')
  $management_ipv6 = hiera('profile::networks::management::ipv6::prefix')

  include ::profile::monitoring::munin::node::firewall
  include ::profile::monitoring::munin::plugin::general
  include ::profile::monitoring::munin::plugin::puppet

  class {'::munin::node':
    purge_configs  => true,
    service_ensure => 'running',
  }
}
