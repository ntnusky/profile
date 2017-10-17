# Keepalived config for management haproxy servers
class profile::services::keepalived::haproxy::management {
  require ::profile::services::keepalived

  $ip = hiera('profile::haproxy::management::ip')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)
  $vrrp_id = hiera('profile::haproxy::management::vrrp::id')
  $vrrp_priority = hiera('profile::haproxy::management::vrrp:priority')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $management_if = hiera('profile::interfaces::management')

  keepalived::vrrp::script { 'check_haproxy':
    script => '/usr/bin/killall -0 haproxy',
  }

  if($ipv6) {
    $vip = ["${ip}/32", "${ipv6}/128"]
  } else {
    $vip = ["${ip}/32"]
  }

  keepalived::vrrp::instance { 'management-haproxy':
    interface         => $management_if,
    state             => 'BACKUP',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => $vip,
    track_script      => 'check_haproxy',
  }
}
