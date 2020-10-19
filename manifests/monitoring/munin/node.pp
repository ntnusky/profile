# Defines a generic munin node
class profile::monitoring::munin::node {
  require ::profile::monitoring::munin::deps
  include ::profile::monitoring::munin::node::firewall
  include ::profile::monitoring::munin::plugin::general
  include ::profile::monitoring::munin::plugin::puppet

  class {'::munin::node':
    purge_configs  => true,
    service_ensure => 'running',
  }
}
