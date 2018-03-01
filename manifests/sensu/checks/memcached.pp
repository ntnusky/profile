# Sensu checks for memcached servers
class profile::sensu::checks::memcached {
  sensu::check { 'memcached-status':
    command     => "check-memcached-stats.rb -h 127.0.0.1",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'memcached' ],
  }
}
