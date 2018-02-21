# Keepalived config for public haproxy servers
class profile::services::keepalived::haproxy::services {
  require ::profile::services::keepalived

  $v4_ip = hiera('profile::haproxy::services::ipv4')
  $v4_id = hiera('profile::haproxy::services::ipv4::id')
  $v4_priority = hiera('profile::haproxy::services::ipv4::priority')
  $v6_ip = hiera('profile::haproxy::services::ipv6')
  $v6_id = hiera('profile::haproxy::services::ipv6::id')
  $v6_priority = hiera('profile::haproxy::services::ipv6::priority')

  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $management_if = hiera('profile::interfaces::management')

  keepalived::vrrp::script { 'check_haproxy':
    script => '/usr/bin/killall -0 haproxy',
  }

  keepalived::vrrp::instance { 'services-haproxy-v4':
    interface         => $management_if,
    state             => 'BACKUP',
    virtual_router_id => $v4_id,
    priority          => $v4_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => ["${v4_ip}/32"],
    track_script      => 'check_haproxy',
  }

  keepalived::vrrp::instance { 'services-haproxy-v6':
    interface         => $management_if,
    state             => 'BACKUP',
    virtual_router_id => $v6_id,
    priority          => $v6_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => ["${v6_ip}/64"],
    track_script      => 'check_haproxy',
  }
}
