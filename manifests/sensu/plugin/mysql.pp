# MySQL plugin for sensu
class profile::sensu::plugin::mysql {

  require ::profile::sensu::client

  sensu::plugin { 'sensu-plugins-mysql':
    type => 'package'
  }
}
