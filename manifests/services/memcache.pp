# This class installs and configures a simple memcached server placed behind a
# keepalived VIP.
class profile::services::memcache {
  # Variables for keepalived
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::mysql::vrrp::id')
  $vrpri = hiera('profile::mysql::vrrp::priority')
  $management_if = hiera('profile::interfaces::management')
  
  # Memcache IP
  $memcache_ip = hiera('profile::memcache::ip')

  require profile::services::keepalived
  
  class { 'memcached':
    listen_ip => $memcache_ip,
    tcp_port  => '11211',
    udp_port  => '11211',
  }

  keepalived::vrrp::script { 'check_memcache':
    script => '/usr/bin/killall -0 memcached',
  }

  keepalived::vrrp::instance { 'management-memcached':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${memcache_ip}/32",
    ],
    track_script      => 'check_memcache',
  }
}
