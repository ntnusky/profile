class profile::munin::plugin::ceph {
  munin::plugin { 'ceph_capacity':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/ceph_capacity',
	config => ['user root'],
  }
  munin::plugin { 'ceph_osd':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/ceph_osd',
	config => ['user root'],
  }
}
