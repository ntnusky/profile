# This class installs and configures a simple memcached server
class profile::services::memcache {
  # Variables for keepalived
  $management_if = hiera('profile::interfaces::management')
  $memcached_port = '11211'
  $installsensu = hiera('profile::sensu::install', true)

  # Memcache IP
  $memcache_ipv4 = $::facts['networking']['interfaces'][$management_if]['ip']
  $memcache_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']

  contain ::profile::services::memcache::firewall

  class { 'memcached':
    listen_ip => "${memcache_ipv4},${memcache_ipv6}",
    tcp_port  => $memcached_port,
    udp_port  => $memcached_port,
  }

  if ($installsensu) {
    include ::profile::sensu::plugin::memcached
  }
}
