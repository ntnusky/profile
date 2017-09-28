# Configuring keepalived for the postgres IP
class profile::services::postgresql::keepalived {
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::postgres::vrrp::id')
  $vrpri = hiera('profile::postgres::vrrp::priority')

  $postgresql_ip = hiera('profile::postgres::ip')
  $management_if = hiera('profile::interfaces::management')
  $localip = $facts['networking']['interfaces'][$management_if]['ip']

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_postgresql':
    script  => "/usr/local/bin/check_pgsql_master.bash ${localip} 5432",
    require => File['/usr/local/bin/check_pgsql_master.bash'],
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

  file { '/usr/local/bin/check_pgsql_master.bash':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/keepalived/check_pgsql_master.bash',
  }
}
