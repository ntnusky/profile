# Configuring keepalived for the postgres IP
class profile::services::postgresql::keepalived {
  $vrrp_password = lookup('profile::keepalived::vrrp_password', String)

  $v4ip = lookup('profile::postgres::ipv4', Stdlib::IP::Address::V4)
  $v4id = lookup('profile::postgres::ipv4::id', Integer)
  $v4pri = lookup('profile::postgres::ipv4::priority', {
    'value_type'    => Integer,
    'default_value' => 100,
  })
  $v6ip = lookup('profile::postgres::ipv6', {
    'value_type'    => Variant[Stdlib::IP::Address::V6, Boolean],
    'default_value' => false,
  })
  $v6pri = lookup('profile::postgres::ipv6::priority', {
    'value_type'    => Integer,
    'default_value' => 100,
  })

  # TODO: Stop looking for the management-IP in hiera, and simply just take it
  # from SL.
  if($sl2) {
    $default = $::sl2['server']['primary_interface']['name']
  } else {
    $default = undef
  }

  $management_if = lookup('profile::interfaces::management', {
    'default_value' => $default, 
    'value_type'    => String,
  })
  $autoip = $facts['networking']['interfaces'][$management_if]['ip']
  $localip = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $autoip,
  })

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
    $v6id = lookup('profile::postgres::ipv6::id', Integer)

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
