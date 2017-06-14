# This class sets up keepalived to negotiate for the IP used by glance.
class profile::openstack::glance::keepalived {
  $vrrp_id = hiera('profile::api::glance::vrrp::id')
  $vrrp_priority = hiera('profile::api::glance::vrrp::priority')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')

  $glance_admin_ip = hiera('profile::api::glance::admin::ip')
  $glance_public_ip = hiera('profile::api::glance::public::ip')

  $public_if = hiera('profile::interfaces::public')
  $management_if = hiera('profile::interfaces::management')

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_glance':
    script  => '/usr/bin/killall -0 glance-api',
  }

  keepalived::vrrp::instance { 'admin-glance':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${glance_admin_ip}/32",
    ],
    track_script      => 'check_glance',
  }

  keepalived::vrrp::instance { 'public-glance':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${glance_public_ip}/32",
    ],
    track_script      => 'check_glance',
  }
}
