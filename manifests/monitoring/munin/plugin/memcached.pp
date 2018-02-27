# This class installs munin plugins for monitorin memcached stats
class profile::monitoring::munin::plugin::memcached {

  ensure_packages ( [
      'libcache-memcached-perl',
    ], {
      'ensure' => 'present',
    }
  )

  munin::plugin { 'memcached_rates':
    ensure => link,
    target => 'memcached_',
  }
  munin::plugin { 'memcached_bytes':
    ensure => link,
    target => 'memcached_',
  }
  munin::plugin { 'memcached_counters':
    ensure => link,
    target => 'memcached_',
  }
}
