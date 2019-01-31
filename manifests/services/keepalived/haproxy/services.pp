# Keepalived config for public haproxy servers
class profile::services::keepalived::haproxy::services {
  $v4_ip = lookup('profile::haproxy::management::ipv4', {
    'value_type' => Variant[String, Boolean],
    'default_value' => false,
  })
  $v6_ip = lookup('profile::haproxy::management::ipv6', {
    'value_type' => Variant[String, Boolean],
    'default_value' => false,
  })

  if ( $v4_ip or $v6_ip ) {
    require ::profile::services::keepalived

    $vrrp_password = lookup('profile::keepalived::vrrp_password')
    $services_if = lookup('profile::interfaces::management')

    keepalived::vrrp::script { 'check_haproxy':
      script => '/usr/bin/killall -0 haproxy',
    }
  }

  if ( $v4_ip ) {
    $v4_id = lookup('profile::haproxy::management::ipv4::id')
    $v4_priority = lookup('profile::haproxy::management::ipv4::priority')

    keepalived::vrrp::instance { 'services-haproxy-v4':
      interface         => $services_if,
      state             => 'BACKUP',
      virtual_router_id => $v4_id,
      priority          => $v4_priority,
      auth_type         => 'PASS',
      auth_pass         => $vrrp_password,
      virtual_ipaddress => ["${v4_ip}/32"],
      track_script      => 'check_haproxy',
    }
  }

  if ( $v6_ip ) {
    $v6_id = lookup('profile::haproxy::management::ipv6::id')
    $v6_priority = lookup('profile::haproxy::management::ipv6::priority')

    keepalived::vrrp::instance { 'services-haproxy-v6':
      interface         => $services_if,
      state             => 'BACKUP',
      virtual_router_id => $v6_id,
      priority          => $v6_priority,
      auth_type         => 'PASS',
      auth_pass         => $vrrp_password,
      virtual_ipaddress => ["${v6_ip}/64"],
      track_script      => 'check_haproxy',
    }
  }
}
