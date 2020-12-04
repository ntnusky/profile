# This class installs munin plugins which monitors the ceph cluster. Should be
# installed on the ceph monitors.
class profile::monitoring::munin::plugin::ceph {
  require ::profile::monitoring::munin::plugin::ceph::base

  $plugins = [
    'ceph_activity_iops',
    'ceph_activity_traffic',
    'ceph_class_osd',
    'ceph_class_pg',
    'ceph_class_storage',
    'ceph_objects',
    'ceph_osd',
    'ceph_pg',
    'ceph_storage',
    'ceph_total',
  ]

  $plugins.each | $plugin | {
    munin::plugin { $plugin:
      ensure => present,
      source => "puppet:///modules/profile/muninplugins/${plugin}",
      config => ['user root'],
    }
  }

  # This class is basicly for cleaning up old ceph-collector plugins and
  # collectors. 
  $pools = ['rbd', 'volumes', 'images']
  $pools.each | $pool | {
    ::profile::ceph::monitoring::pool { $pool: }
  }
}
