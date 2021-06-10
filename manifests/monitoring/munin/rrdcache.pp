# Install the RRD Cache Daemon and perl bindings
class profile::monitoring::munin::rrdcache {
  include rrd::cache
  include rrd::bindings::perl
}
