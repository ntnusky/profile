# This class installs and configures a simple memcached server
class profile::services::memcache {
  # Variables for keepalived
  if($sl2) {
    $default = $::sl2['server']['primary_interface']['name']
  } else {
    $default = undef
  }

  $management_if = lookup('profile::interfaces::management', {
    'default_value' => $default, 
    'value_type'    => String,
  })
  $memcached_port = lookup('profile::memcache::port', {
    'value_type'    => Stdlib::Port,
    'default_value' => 11211,
  })
  $installsensu = lookup('profile::sensu::install', {
    'value_type'    => Boolean,
    'default_value' => true,
  })
  $installmunin = lookup('profile::munin::install', {
    'value_type'    => Boolean,
    'default_value' => true,
  })
  $use_keepalived = lookup('profile::memcache::keepalived', {
    'value_type'    => Boolean,
    'default_value' => false,
  })

  if ( $use_keepalived ) {
    contain ::profile::services::memcache::keepalived
    $memcache_ip = lookup('profile::memcache::ip', Stdlib::IP::Address::V4)
    $listen = [$memcache_ip]
  } else {
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

  if ($installsensu) {
    include ::profile::sensu::plugin::memcached
    sensu::subscription { 'memcached': }
  }
  if($installmunin) {
    include ::profile::monitoring::munin::plugin::memcached
  }
}
