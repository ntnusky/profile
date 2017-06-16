# Configures keepalived to negotiate for the horizon address.
class profile::openstack::horizon::keepalived {
  $horizon_ip = hiera('profile::api::horizon::public::ip')

  $vrrp_id = hiera('profile::api::horizon::vrrp::id')
  $vrrp_priority = hiera('profile::api::horizon::vrrp::priority')
  $vrrp_password     = hiera('profile::keepalived::vrrp_password')

  $public_if = hiera('profile::interfaces::public')

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_horizon':
    script => '/usr/bin/killall -0 apache2',
  }

  keepalived::vrrp::instance { 'public-horizon':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${horizon_ip}/32",
    ],
    track_script      => 'check_horizon',
  }
}
