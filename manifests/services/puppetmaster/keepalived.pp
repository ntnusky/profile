# Configuring keepalived for the puppetmaster IP
class profile::services::puppetmaster::keepalived {
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::puppet::vrrp::id')
  $vrpri = hiera('profile::puppet::vrrp::priority')

  $puppet_ip = hiera('profile::puppet::ip')
  $management_if = hiera('profile::interfaces::management')

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_puppetmaster':
    script => '/bin/systemctl -q is-active puppetserver',
  }

  keepalived::vrrp::instance { 'puppetmaster':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${puppet_ip}/32",
    ],
    track_script      => 'check_puppetmaster',
  }
}
