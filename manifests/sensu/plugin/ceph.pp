# Ceph plugin for sensu
class profile::sensu::plugin::ceph {

  require ::profile::sensu::client

  sensu::plugin { 'sensu-plugins-ceph':
    type => 'package'
  }
}
