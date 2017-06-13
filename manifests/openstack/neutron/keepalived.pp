# Configures the keepalived daemon for the neutron api.
class profile::openstack::neutron::keepalived {
  $vrrp_id = hiera('profile::api::neutron::vrrp::id')
  $vrrp_priority = hiera('profile::api::neutron::vrrp::priority')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $management_if = hiera('profile::interfaces::management')
  $public_if = hiera('profile::interfaces::public')
  $public_ip = hiera('profile::api::neutron::public::ip')
  $admin_ip = hiera('profile::api::neutron::admin::ip')

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_neutron':
    script  => '/usr/bin/killall -0 neutron-server',
  }

  keepalived::vrrp::instance { 'admin-neutron':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${admin_ip}/32",
    ],
    track_script      => 'check_neutron',
  }

  keepalived::vrrp::instance { 'public-neutron':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${public_ip}/32",
    ],
    track_script      => 'check_neutron',
  }
}
