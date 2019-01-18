# This class installs munin plugins which monitors the ceph cluster. Should be
# installed on the ceph monitors.
class profile::monitoring::munin::plugin::ceph {
  require ::profile::monitoring::munin::plugin::ceph::base
  include ::profile::monitoring::munin::plugin::ceph::systemd

  munin::plugin { 'ceph_total':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/ceph_total',
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

  munin::plugin { 'ceph_traffic_volumes':
    ensure  => link,
    target  => 'ceph_traffic_',
    require => File['/usr/share/munin/plugins/ceph_traffic_'],
    config  => ['user root'],
  }
  munin::plugin { 'ceph_traffic_rbd':
    ensure  => link,
    target  => 'ceph_traffic_',
    require => File['/usr/share/munin/plugins/ceph_traffic_'],
    config  => ['user root'],
  }
  munin::plugin { 'ceph_traffic_images':
    ensure  => link,
    target  => 'ceph_traffic_',
    require => File['/usr/share/munin/plugins/ceph_traffic_'],
    config  => ['user root'],
  }
  munin::plugin { 'ceph_iops_volumes':
    ensure  => link,
    target  => 'ceph_iops_',
    require => File['/usr/share/munin/plugins/ceph_iops_'],
    config  => ['user root'],
  }
  munin::plugin { 'ceph_iops_rbd':
    ensure  => link,
    target  => 'ceph_iops_',
    require => File['/usr/share/munin/plugins/ceph_iops_'],
    config  => ['user root'],
  }
  munin::plugin { 'ceph_iops_images':
    ensure  => link,
    target  => 'ceph_iops_',
    require => File['/usr/share/munin/plugins/ceph_iops_'],
    config  => ['user root'],
  }
}
