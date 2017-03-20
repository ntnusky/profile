# rabbitmq plugin for sensu
class profile::sensu::plugin::rabbitmq {
  sensu::plugin { 'sensu-plugins-rabbitmq':
    type => 'package'
  }
}
