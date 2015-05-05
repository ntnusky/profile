class profile::rabbitmq {
  $rabbituser = hiera("profile::rabbitmq::rabbituser")
  $rabbitpass = hiera("profile::rabbitmq::rabbitpass")
  $secret     = hiera("profile::rabbitmq::rabbitsecret")
  $ctrlnodes  = hiera("controllernames")

  class { '::rabbitmq': 
    config_cluster    => true,
    cluster_nodes     => $ctrlnodes,
    cluster_node_type => 'ram',
    erlang_cookie     => $secret,
    wipe_db_on_cookie_change => true,
  }

  rabbitmq_user { $rabbituser:
    admin    => true,
    password => $rabbitpass,
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
  rabbitmq_user_permissions { "${rabbituser}@/":
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
    require              => Rabbitmq_user[$rabbituser},
  }
}
