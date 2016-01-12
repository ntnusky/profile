class profile::munin::master {
  class{ '::munin::master':
    html_strategy => 'cron',
	graph_strategy => 'cron',
  }
}
