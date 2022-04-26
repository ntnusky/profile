# sudo config for rabbitmq
class profile::services::rabbitmq::sudo {
  sudo::conf { 'rabbitmq':
    priority => 50,
    source   => 'puppet:///modules/profile/sudo/rabbitmq_sudoers',
  }
}
