# Defines a generic munin node
class profile::monitoring::munin::node {
  $installmunin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  if($installmunin) {
    include ::profile::monitoring::munin::node::firewall
    include ::profile::monitoring::munin::plugin::general
    include ::profile::monitoring::munin::plugin::puppet
    require ::profile::repo::powertools

    class {'::munin::node':
      purge_configs  => true,
      service_ensure => 'running',
    }
  } else {
    package { 'munin-node':
      ensure => purged,
    }
  }
}
