# Configures keepalived to negotiate for the cinder IP address.
class profile::openstack::cinder::keepalived {
  $vrrp_id = hiera('profile::api::cinder::vrrp::id')
  $vrrp_priority = hiera('profile::api::cinder::vrrp::priority')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')

  $management_if = hiera('profile::interfaces::management')
  $public_if = hiera('profile::interfaces::public')

  $cinder_admin_ip = hiera('profile::api::cinder::admin::ip')
  $cinder_public_ip = hiera('profile::api::cinder::public::ip')

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_cinder':
    script  => '/usr/bin/killall -0 cinder-api',
  }

  keepalived::vrrp::instance { 'admin-cinder':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${cinder_admin_ip}/32",
    ],
    track_script      => 'check_cinder',
  }

  keepalived::vrrp::instance { 'public-cinder':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${cinder_public_ip}/32",
    ],
    track_script      => 'check_cinder',
  }
}
