# Sensu checks for haproxy servers
class profile::sensu::checks::haproxy {
  sensu::check { 'haproxy-stats':
    command     => 'check-haproxy.rb -S localhost -q / -P 9000 -A',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'haproxy-servers' ],
  }
}
