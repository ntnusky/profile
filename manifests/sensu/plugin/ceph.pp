# Ceph plugin for sensu
class profile::sensu::plugin::ceph {
  sensu::plugin { 'sensu-plugins-ceph':
    type = 'package'
  }
}
