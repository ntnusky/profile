# This class installs and configures a simple memcached server
class profile::services::memcache {
  # Variables for keepalived
  $management_if = hiera('profile::interfaces::management')
  $memcached_port = hiera('profile::memcache::port', '11211')
  $installsensu = hiera('profile::sensu::install', true)
  $installmunin = hiera('profile::munin::install', true)
  $use_keepalived = hiera('profile::memcache::keepalived', false)

  if ( $use_keepalived ) {
    contain ::profile::services::memcache::keepalived
    $memcache_ip = hiera('profile::memcache::ip')
    $listen = $memcache_ip
  } else {
    $autoip = $::facts['networking']['interfaces'][$management_if]['ip']
    $memcache_ipv4 = hiera("profile::interfaces::${management_if}::address", $autoip)
    $memcache_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']
    if ( $memcache_ipv6 =~ /^fe80/ ) {
      $listen = $memcache_ipv4
    } else {
      $listen = "${memcache_ipv4},${memcache_ipv6}"
    }
  }

  contain ::profile::services::memcache::firewall

  class { 'memcached':
    listen_ip  => "127.0.0.1,${listen}",
    max_memory => '75%',
    tcp_port   => $memcached_port,
    udp_port   => $memcached_port,
  }

  if ($installsensu) {
    include ::profile::sensu::plugin::memcached
    sensu::subscription { 'memcached': }
  }
  if($installmunin) {
    include ::profile::monitoring::munin::plugin::memcached
  }
}
