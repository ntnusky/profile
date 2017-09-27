# Configuring keepalived for the puppetdb IP
class profile::services::puppetdb::keepalived {
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::puppetdb::vrrp::id')
  $vrpri = hiera('profile::puppetdb::vrrp::priority')

  $puppetdb_ip = hiera('profile::puppetdb::ip')
  $management_if = hiera('profile::interfaces::management')

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_puppetdb':
    script => '/bin/systemctl -q is-active puppetdb',
  }

  keepalived::vrrp::instance { 'puppetdb':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${puppetdb_ip}/32",
    ],
    track_script      => 'check_puppetdb',
  }
}
