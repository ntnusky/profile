# Remove the old ceph-collector.sh based plugins for monitoring.
class profile::monitoring::munin::plugin::ceph::base {
  file { '/usr/share/munin/plugins/ceph_traffic_':
    ensure => absent,
  }
  file { '/usr/share/munin/plugins/ceph_iops_':
    ensure => absent,
  }
}
