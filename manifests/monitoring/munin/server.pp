# This class installs a munin server, and configures an apache virtuaø-host
# responding to its name. 
class profile::monitoring::munin::server {
  $munin_urls = hiera('profile::munin::urls')

  contain ::profile::monitoring::munin::haproxy::balancermember

  class{ '::munin::master':
    extra_config => [
      'cgiurl_graph /munin-cgi/munin-cgi-graph',
      'graph_data_size huge',
    ],
  }

  ::munin::plugin { 'munin_stats':
    ensure  => link,
  }

  ::profile::monitoring::munin::server::vhost { $munin_urls : }
}
