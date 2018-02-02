# Configure keepalived for memcached
class profile::services::memcache::keepalived {
  # Variables for keepalived
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::memcache::vrrp::id')
  $vrpri = hiera('profile::memcache::vrrp::priority')
  $management_if = hiera('profile::interfaces::management')

  # Memcache IP
  $memcache_ip = hiera('profile::memcache::ip')

  require ::profile::services::keepalived

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
