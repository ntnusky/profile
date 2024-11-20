# This class installs and configures a simple memcached server
class profile::services::memcache {
  $management_if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'], 
    'value_type'    => String,
  })
  $memcached_port = lookup('profile::memcache::port', {
    'value_type'    => Stdlib::Port,
    'default_value' => 11211,
  })

  $autoip = $::facts['networking']['interfaces'][$management_if]['ip']
  $memcache_ipv4 = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $autoip,
  })
  $memcache_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']
  if ( $memcache_ipv6 =~ /^fe80/ ) {
    $listen = [$memcache_ipv4]
  } else {
    $listen = [$memcache_ipv4,$memcache_ipv6]
  }

  contain ::profile::services::memcache::firewall
  include ::profile::services::memcache::sudo

  class { 'memcached':
    pidfile    => '/var/run/memcached/memcached.pid',
    user       => 'memcache',
    listen_ip  => ['127.0.0.1'] + $listen,
    max_memory => '75%',
    tcp_port   => $memcached_port,
    udp_port   => $memcached_port,
  }

  profile::utilities::logging::journald { 'memcached.service' : }
}
