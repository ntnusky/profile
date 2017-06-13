# Konfigures the keepalived for keystone
class profile::openstack::keystone::keepalived {
  $admin_ip = hiera('profile::api::keystone::admin::ip')
  $public_ip = hiera('profile::api::keystone::public::ip')
  $vrrp_id = hiera('profile::api::keystone::vrrp::id')
  $vrrp_priority = hiera('profile::api::keystone::vrrp::priority')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')

  $public_if = hiera('profile::interfaces::public')
  $management_if = hiera('profile::interfaces::management')

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_keystone':
    script  => '/usr/bin/killall -0 keystone-all',
  }

  keepalived::vrrp::instance { 'admin-keystone':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${admin_ip}/32",
    ],
    track_script      => 'check_keystone',
  }

  keepalived::vrrp::instance { 'public-keystone':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${public_ip}/32",
    ],
    track_script      => 'check_keystone',
  }
}
