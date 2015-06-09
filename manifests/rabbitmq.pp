class profile::rabbitmq {
  $if_management = hiera("profile::interface::management")
  $rabbit_ip = hiera("profile::rabbitmq::ip")
  $vrrp_password = hiera("profile::keepalived::vrrp_password")
  $vrid = hiera("profile::rabbitmq::vrrp::id")
  $vrpri = hiera("profile::rabbitmq::vrrp::priority")

  $rabbituser = hiera("profile::rabbitmq::rabbituser")
  $rabbitpass = hiera("profile::rabbitmq::rabbitpass")
  $secret     = hiera("profile::rabbitmq::rabbitsecret")
  $ctrlnodes  = hiera("controller::names")

  class { '::rabbitmq': 
    erlang_cookie     => $secret,
    wipe_db_on_cookie_change => true,
  }->
  rabbitmq_user { $rabbituser:
    admin    => true,
    password => $rabbitpass,
    provider => 'rabbitmqctl',
  } ->
  rabbitmq_user_permissions { "${rabbituser}@/":
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
    before               => Anchor['profile::rabbitmq::end'],
  }

  keepalived::vrrp::script { 'check_rabbitmq':
    #script => '/usr/sbin/service rabbitmq-server status',
    script => '/usr/sbin/rabbitmqctl report',
  }

  keepalived::vrrp::instance { 'public-rabbitmq':
    interface         => $if_management,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password, 
    virtual_ipaddress => [
      "${rabbit_ip}/32",	
    ],
    track_script      => 'check_rabbitmq',
  }
  anchor { "profile::rabbitmq::end" : 
    require => [Keepalived::Vrrp::Instance['public-rabbitmq'], 
              Keepalived::Vrrp::Script['check_rabbitmq']],
  }
}
