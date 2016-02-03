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

  # Install the collector scripts for the ceph plugins
  file { '/usr/local/sbin/ceph-collector.sh':
    ensure => file,
	mode => 755,
	owner => root,
	group => root,
    source => 'puppet:///modules/profile/muninplugins/ceph-collector.sh',
  }
  file { '/usr/local/sbin/ceph-collect.sh':
    ensure => file,
	mode => 755,
	owner => root,
	group => root,
    source => 'puppet:///modules/profile/muninplugins/ceph-collect.sh',
  }
}
