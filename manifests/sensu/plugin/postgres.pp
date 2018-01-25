# MySQL plugin for sensu
class profile::sensu::plugin::postgres {

  require ::profile::sensu::client

  sensu::plugin { 'sensu-plugins-postgres':
    type => 'package'
  }
}
