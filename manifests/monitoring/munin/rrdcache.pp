# Install the RRD Cache Daemon and perl bindings
class profile::monitoring::munin::rrdcache {
  class { 'rrd::cache':
    uid         => 'munin',
    gid         => 'www-data',
    socket_mode => '766',
  }
  include rrd::bindings::perl
}
