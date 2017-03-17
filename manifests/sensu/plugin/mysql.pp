# MySQL plugin for sensu
class profile::sensu::plugin::mysql {
  sensu::plugin { 'sensu-plugins-mysql':
    type => 'package'
  }
}
