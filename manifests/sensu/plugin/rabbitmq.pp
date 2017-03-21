# rabbitmq plugin for sensu
class profile::sensu::plugin::rabbitmq {

  require ::profile::sensu::client

  sensu::plugin { 'sensu-plugins-rabbitmq':
    type => 'package'
  }
}
