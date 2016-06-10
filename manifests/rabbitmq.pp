class profile::rabbitmq {
  $if_management = hiera("profile::interfaces::management")
  $rabbit_ip = hiera("profile::rabbitmq::ip")
  $vrrp_password = hiera("profile::keepalived::vrrp_password")
  $vrid = hiera("profile::rabbitmq::vrrp::id")
  $vrpri = hiera("profile::rabbitmq::vrrp::priority")

  $rabbituser = hiera("profile::rabbitmq::rabbituser")
  $rabbitpass = hiera("profile::rabbitmq::rabbitpass")
  $secret     = hiera("profile::rabbitmq::rabbitsecret")
  $ctrlnodes  = hiera("controller::names")

  apt_key { 'rabbitmq-release-key':
    ensure => 'present',
    id     => '6B73A36E6026DFCA',
	source => 'https://bintray.com/rabbitmq/Keys/download_file?file_path=rabbitmq-release-signing-key.asc',
  }->
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
    script => "bash -c '[[ $(/usr/sbin/rabbitmqctl status | grep -c rabbit) -ge 2 ]]'",
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
