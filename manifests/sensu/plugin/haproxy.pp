# haproxy plugin for sensu
class profile::sensu::plugin::haproxy {

  require ::profile::sensu::client

  sensu::plugin { 'sensu-plugins-haproxy':
    type => 'package'
  }
}
