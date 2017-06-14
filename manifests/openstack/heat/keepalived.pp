# Configures keepalived to negotiate for the heat API IP.
class profile::openstack::heat::keepalived {
  $management_if = hiera('profile::interfaces::management')
  $public_if = hiera('profile::interfaces::public')

  $heat_admin_ip = hiera('profile::api::heat::admin::ip')
  $heat_public_ip = hiera('profile::api::heat::public::ip')

  $vrrp_id = hiera('profile::api::heat::vrrp::id')
  $vrrp_priority = hiera('profile::api::heat::vrrp::priority')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_heat':
    script => '/usr/bin/killall -0 heat-api',
  }

  keepalived::vrrp::instance { 'admin-heat':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${heat_admin_ip}/32",
    ],
    track_script      => 'check_heat',
  }

  keepalived::vrrp::instance { 'public-heat':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${heat_public_ip}/32",
    ],
    track_script      => 'check_heat',
  }
}
