# Remove the old ceph-metric-collectors for munin-monitoring..
class profile::ceph::monitoring::collectors {
  file { '/usr/local/sbin/ceph-collector.sh':
    ensure  => absent,
  }
  file { '/usr/local/sbin/ceph-collect.sh':
    ensure => absent,
  }
}
