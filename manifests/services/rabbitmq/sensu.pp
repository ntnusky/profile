# Creates rabbitmq user and vhost for sensu
class profile::services::rabbitmq::sensu {

  require ::profile::services::rabbitmq

  $sensurabbitpass = hiera('profile::sensu::rabbit_password')

  rabbitmq_user { 'sensu':
    admin    => false,
    password => $sensurabbitpass,
    provider => 'rabbitmqctl',
  } ->

  rabbitmq_vhost { 'sensu':
    ensure => 'present',
  }

  rabbitmq_user_permissions { 'sensu@/sensu':
    configure_permissions => '.*',
    write_permission      => '.*',
    read_permission       => '.*',
    provider              => 'rabbitmqctl',
  }
}
