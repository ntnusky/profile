# Creates rabbitmq user and vhost for sensu
class profile::services::rabbitmq::sensu {

  $sensurabbitpass = lookup('profile::sensu::rabbit_password', String)
  $rabbithosts = lookup('profile::rabbitmq::servers', {
    'default_value' => false,
    'value_type'    => Variant[Array[String], Boolean]
  })

  rabbitmq_user { 'sensu':
    admin    => false,
    password => $sensurabbitpass,
    provider => 'rabbitmqctl',
  }
  -> rabbitmq_vhost { '/sensu':
    ensure => 'present',
  }
  -> rabbitmq_user_permissions { 'sensu@/sensu':
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }

  if ( $rabbithosts ) {
    rabbitmq_policy { 'ha-sensu@/sensu':
      pattern    => '^(results$|keepalives$)',
      definition => {
        'ha-mode'      => 'all',
        'ha-sync-mode' => 'automatic',
      },
      require    => Rabbitmq_vhost['/sensu']
    }
  }
}
