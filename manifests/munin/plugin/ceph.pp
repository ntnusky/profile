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
  munin::plugin { 'ceph_usage':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/ceph_usage',
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
  
  # Install the munin plugins
  file { '/usr/share/munin/plugins/ceph_traffic_':
    ensure => file,
	mode => 755,
	owner => root,
	group => root,
    source => 'puppet:///modules/profile/muninplugins/ceph_traffic_',
  }
  file { '/usr/share/munin/plugins/ceph_iops_':
    ensure => file,
	mode => 755,
	owner => root,
	group => root,
    source => 'puppet:///modules/profile/muninplugins/ceph_iops_',
  }

  munin::plugin { "ceph_traffic_volumes":
    ensure => link,
	target => 'ceph_traffic_',
	require => File['/usr/share/munin/plugins/ceph_traffic_'],
	config => ['user root'],
  }
  munin::plugin { "ceph_traffic_rbd":
    ensure => link,
	target => 'ceph_traffic_',
	require => File['/usr/share/munin/plugins/ceph_traffic_'],
	config => ['user root'],
  }
  munin::plugin { "ceph_traffic_images":
    ensure => link,
	target => 'ceph_traffic_',
	require => File['/usr/share/munin/plugins/ceph_traffic_'],
	config => ['user root'],
  }
  munin::plugin { "ceph_iops_volumes":
    ensure => link,
	target => 'ceph_iops_',
	require => File['/usr/share/munin/plugins/ceph_iops_'],
	config => ['user root'],
  }
  munin::plugin { "ceph_iops_rbd":
    ensure => link,
	target => 'ceph_iops_',
	require => File['/usr/share/munin/plugins/ceph_iops_'],
	config => ['user root'],
  }
  munin::plugin { "ceph_iops_images":
    ensure => link,
	target => 'ceph_iops_',
	require => File['/usr/share/munin/plugins/ceph_iops_'],
	config => ['user root'],
  }
}
