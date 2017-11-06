# Defines a generic munin node
class profile::monitoring::munin::node {
  $management_if = hiera('profile::interfaces::management')
  $management_ip = $::facts['networking']['interfaces'][$management_if]['ip']

  $management_ipv4 = hiera('profile::networks::management::ipv4::prefix')
  $management_ipv6 = hiera('profile::networks::management::ipv6::prefix')

  include ::profile::monitoring::munin::node::firewall
  include ::profile::monitoring::munin::plugin::general
  include ::profile::monitoring::munin::plugin::puppet

  class {'::munin::node':
    bind_address   => $management_ip,
    allow          => [$management_ipv4, $management_ipv6], 
    purge_configs  => true,
    service_ensure => 'running',
  }
}
