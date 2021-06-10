# Install the RRD Cache Daemon and perl bindings
class profile::monitoring::munin::rrdcache {
  class { 'rrd::cache':
    gid => 'munin',
  }
  include rrd::bindings::perl
}
