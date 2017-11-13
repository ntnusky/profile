# memcached plugin for sensu
class profile::sensu::plugin::memcached {

  require ::profile::sensu::client

  sensu::plugin { 'sensu-plugins-memcached':
    type => 'package'
  }
}
