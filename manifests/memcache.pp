class profile::memcache {
  $ip = hiera("profile::memcache::ip")
  anchor { "profile::memcache::start" : } ->
  class { 'memcached':
    listen_ip => $ip,
    tcp_port  => '11211',
    udp_port  => '11211',
  }->
  anchor { "profile::memcache::end" : }
}
