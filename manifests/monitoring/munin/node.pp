# Defines a generic munin node
class profile::monitoring::munin::node {
  $management_ipv4 = hiera('profile::networks::management::ipv4::prefix')
  $management_ipv6 = hiera('profile::networks::management::ipv6::prefix')

  include ::profile::monitoring::munin::node::firewall
  include ::profile::monitoring::munin::plugin::general
  include ::profile::monitoring::munin::plugin::puppet

  class {'::munin::node':
    allow          => [
      '127.0.0.0/8',
      '::1/128',
      $management_ipv4,
      $management_ipv6,
    ],
    purge_configs  => true,
    service_ensure => 'running',
  }
}
