# This class installs a munin server, and configures an apache virtuaø-host
# responding to its name. 
class profile::services::munin::server {
  $munin_urls = hiera('profile::munin::urls')

  class{ '::munin::master':
    extra_config => [
      'cgiurl_graph /munin-cgi/munin-cgi-graph',
      'graph_data_size huge',
    ],
  }

  ::munin::plugin { 'munin_stats':
    ensure  => link,
  }

  ::profile::services::munin::server::vhost { $munin_main_urls : }
}
