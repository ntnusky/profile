# Configuring keepalived for the postgres IP
class profile::services::postgresql::keepalived {
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  
  $v4ip = hiera('profile::postgres::ipv4')
  $v4id = hiera('profile::postgres::ipv4::id')
  $v4pri = hiera('profile::postgres::ipv4::priority')
  $v6ip = hiera('profile::postgres::ipv6', false)
  $v6id = hiera('profile::postgres::ipv6::id', false)
  $v6pri = hiera('profile::postgres::ipv6::priority', false)

  $management_if = hiera('profile::interfaces::management')
  $localip = $facts['networking']['interfaces'][$management_if]['ip']

  require ::profile::services::keepalived

  keepalived::vrrp::script { 'check_postgresql':
    script  => "/usr/local/bin/check_pgsql_master.bash ${localip} 5432",
    require => File['/usr/local/bin/check_pgsql_master.bash'],
    weight  => '-10',
  }

  file { '/usr/local/bin/check_pgsql_master.bash':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/keepalived/check_pgsql_master.bash',
  }

  keepalived::vrrp::instance { 'postgresql-database':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $v4id,
    priority          => $v4pri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${v4ip}/32",
    ],
    track_script      => 'check_postgresql',
  }

  if($v6ip) {
    keepalived::vrrp::instance { 'postgresql-database-ipv6':
      interface         => $management_if,
      state             => 'MASTER',
      virtual_router_id => $v6id,
      priority          => $v6pri,
      auth_type         => 'PASS',
      auth_pass         => $vrrp_password,
      virtual_ipaddress => [
        "${v6ip}/64",
      ],
      track_script      => 'check_postgresql',
    }
  }
}
