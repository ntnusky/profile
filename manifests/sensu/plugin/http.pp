# HTTP plugin for sensu
class profile::sensu::plugin::http {
  sensu::plugin { 'sensu-plugins-http':
    type => 'package'
  }
}
