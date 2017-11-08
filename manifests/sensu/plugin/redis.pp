# redis plugin for sensu
class profile::sensu::plugin::redis {

  require ::profile::sensu::client

  sensu::plugin { 'sensu-plugins-redis':
    type => 'package'
  }
}
