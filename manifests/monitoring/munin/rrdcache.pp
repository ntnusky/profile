# Install the RRD Cache Daemon and perl bindings
class profile::monitoring::munin::rrdcache {
  class { 'rrd::cache':
    gid => 'www-data',
  }
  include rrd::bindings::perl
}
