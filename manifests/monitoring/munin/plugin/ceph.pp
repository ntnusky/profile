# This class installs munin plugins which monitors the ceph cluster. Should be
# installed on the ceph monitors.
class profile::monitoring::munin::plugin::ceph {
  require ::profile::monitoring::munin::plugin::ceph::base

  # Add general ceph-related graphs.
  munin::plugin { 'ceph_total':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/ceph_total',
    config => ['user root'],
  }
  munin::plugin { 'ceph_objects':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/ceph_objects',
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

  # Enable the ceph dashboard, as the ceph_activity_* plugins get its data from
  # there.
  $jq = '/usr/bin/jq \'.["enabled_modules"]\''
  exec { 'Enable ceph dashboards':
    command => 'ceph mgr module enable dashboard',
    unless  => "/usr/bin/ceph mgr module ls | ${jq} | /bin/grep -c 'dashboard'",
  }

  # These ceph activity-plugins should replace the ceph-collector(s).sh scripts
  # currently being used.
  munin::plugin { 'ceph_activity_iops':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/ceph_activity_iops',
    config => ['user root'],
  }
  munin::plugin { 'ceph_activity_traffic':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/ceph_activity_traffic',
    config => ['user root'],
  }

  # Add monitoring for specific pools with the ceph-collector(s).sh scripts
  $pools = ['rbd', 'volumes', 'images']
  $pools.each | $pool | {
    ::profile::ceph::monitoring::pool { $pool: }
  }
}
