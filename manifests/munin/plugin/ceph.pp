class profile::munin::plugin::ceph {
  munin::plugin { 'ceph_capacity':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/ceph_capacity',
  }
  munin::plugin { 'ceph_osd':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/ceph_osd',
  }
}
