# Installs and configures a rabbitmq server for our openstack environment.
class profile::services::rabbitmq {
  # Rabbit credentials
  $rabbituser = lookup('profile::rabbitmq::rabbituser')
  $rabbitpass = lookup('profile::rabbitmq::rabbitpass')
  $secret     = lookup('profile::rabbitmq::rabbitsecret')
  $cluster_nodes = lookup('profile::rabbitmq::servers', {
    'default_value' => false,
  })
  $management_netv6 = lookup('profile::networks::management::ipv6::prefix', {
    'default_value' => false,
  })

  $install_munin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })
  $install_sensu = lookup('profile::sensu::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  $distro = $facts['os']['release']['major']

  if ($distro == '20.04') {
    require ::profile::services::erlang
  }
  include ::profile::services::rabbitmq::firewall
  include ::profile::services::rabbitmq::sudo

  if ( $cluster_nodes ) {
    $cluster_config = {
      config_cluster => true,
      cluster_nodes  =>  $cluster_nodes,
    }

    rabbitmq_policy { 'ha-all@/':
      pattern    => '^(?!amq\.).*',
      definition => {
        'ha-mode' => 'all',
      },
      require    => Class['rabbitmq'],
    }
  } else {
    $cluster_config = {}
  }

  include ::profile::services::keepalived::uninstall

  if ( $management_netv6 ) {
    $ipv6 = true
  } else {
    $ipv6 = false
  }

  class { '::rabbitmq':
    erlang_cookie            => $secret,
    manage_python            => false,
    repos_ensure             => true,
    wipe_db_on_cookie_change => true,
    ipv6                     => $ipv6,
    *                        => $cluster_config,
  }
  -> rabbitmq_user { $rabbituser:
    admin    => true,
    password => $rabbitpass,
    provider => 'rabbitmqctl',
  }
  -> rabbitmq_user_permissions { "${rabbituser}@/":
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }

  profile::utilities::logging::module { 'rabbitmq' :
    content => [{
      'module' => 'rabbitmq',
      'log'    => {
        'enabled'   => true,
        'var.paths' => [ "/var/log/rabbitmq/rabbit@${::hostname}.log" ],
      },
    }]
  }

  # Install munin plugins for monitoring.
  if($install_munin) {
    include ::profile::monitoring::munin::plugin::rabbitmq
  }

  # Include rabbitmq configuration for sensu. And the plugin
  if ($install_sensu) {
    include ::profile::services::rabbitmq::sensu
    include ::profile::sensu::plugin::rabbitmq
    sensu::subscription { 'rabbitmq': }
  }
}
