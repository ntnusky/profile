# Configuring keepalived for the postgres IP
class profile::services::postgresql::keepalived {
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::postgresql::vrrp::id')
  $vrpri = hiera('profile::postgresql::vrrp::priority')

  $postgresql_ip = hiera('profile::postgresql::ip')
  $management_if = hiera('profile::interfaces::management')

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_postgresql':
    script => '/usr/bin/killall -0 postgres',
  }

  keepalived::vrrp::instance { 'postgresql-database':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${postgresql_ip}/32",
    ],
    track_script      => 'check_postgresql',
  }
}
