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

  $install_munin = lookup('profile::munin::install', {
    'value_type'    => Boolean,
  })

  require ::profile::monitoring::munin::rrdcache
  contain ::profile::monitoring::munin::haproxy::balancermember

  # If we should run munin; ensure it is installed and configured.
  if($install_munin) {
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

  # If we dont want munin installed anymore; simply stop ensure it is installed
  # and configured. Also make sure to stop the munin-cron. This will leave the
  # historical munin-data in place until we finally deletes the munin-servers.
  } else {
    file { '/etc/cron.d/munin':
      ensure => absent,
    }
  }

  ::profile::monitoring::munin::server::vhost { $munin_urls : }
}
