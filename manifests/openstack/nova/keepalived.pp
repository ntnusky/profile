# Configures keepalived for handeling the IP used by nova
class profile::openstack::nova::keepalived {
  $nova_admin_ip = hiera('profile::api::nova::admin::ip')
  $nova_public_ip = hiera('profile::api::nova::public::ip')
  $vrrp_id = hiera('profile::api::nova::vrrp::id')
  $vrrp_priority = hiera('profile::api::nova::vrrp::priority')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')

  $public_if = hiera('profile::interfaces::public')
  $management_if = hiera('profile::interfaces::management')

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_nova':
    script  => '/usr/bin/killall -0 nova-api',
  }

  keepalived::vrrp::instance { 'admin-nova':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${nova_admin_ip}/32",
    ],
    track_script      => 'check_nova',
  }

  keepalived::vrrp::instance { 'public-nova':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${nova_public_ip}/32",
    ],
    track_script      => 'check_nova',
  }
}
