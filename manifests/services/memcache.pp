# This class installs and configures a simple memcached server placed behind a
# keepalived VIP.
class profile::services::memcache {
  # Variables for keepalived
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::memcache::vrrp::id')
  $vrpri = hiera('profile::memcache::vrrp::priority')
  $management_if = hiera('profile::interfaces::management')
  $source_firewall_management_net = hiera('profile::networks::management')
  $memcached_port = '11211'

  # Memcache IP
  $memcache_ip = hiera('profile::memcache::ip')

  require profile::services::keepalived
  require profile::baseconfig::firewall

  firewall { '500 accept incoming memcached tcp':
    source      => $source_firewall_management_net,
    destination => $memcache_ip,
    proto       => 'tcp',
    dport       => $memcached_port,
    action      => 'accept',
  }
  firewall { '500 accept incoming memcached udp':
    source      => $source_firewall_management_net,
    destination => $memcache_ip,
    proto       => 'udp',
    dport       => $memcached_port,
    action      => 'accept',
  }
  class { 'memcached':
    listen_ip => $memcache_ip,
    tcp_port  => $memcached_port,
    udp_port  => $memcached_port,
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
