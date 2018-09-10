# lvm plugin for sensu
class profile::sensu::plugin::lvm {

  require ::profile::sensu::client

  sensu::plugin { 'sensu-plugins-lvm':
    type => 'package'
  }
}
