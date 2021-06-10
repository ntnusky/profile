# This class installs a munin server, and configures an apache virtuaø-host
# responding to its name. 
class profile::monitoring::munin::server {
  $munin_urls = lookup('profile::munin::urls', {
    'value_type' => Array[Stdlib::Fqdn],
  })
  $max_processes = lookup('profile::munin::master::max_processes', {
    'default_value' => 16,
    'value_type'    => Integer,
  })

  require ::profile::monitoring::munun::rrdcache
  contain ::profile::monitoring::munin::haproxy::balancermember
  include ::profile::monitoring::munin::plugin::snmp

  class{ '::munin::master':
    extra_config => [
      'cgiurl_graph /munin-cgi/munin-cgi-graph',
      'graph_data_size huge',
      'rrdcached_socket /var/run/rrdcached.sock',
      "max_processes ${max_processes}",
    ],
  }

  ::munin::plugin { 'munin_stats':
    ensure  => link,
  }

  ::profile::monitoring::munin::server::vhost { $munin_urls : }
}
