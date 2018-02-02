# This class installs munin plugins which monitors the ceph cluster. Should be
# installed on the ceph monitors.
class profile::munin::monitoring::plugin::ceph {
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

  # Install the collector scripts for the ceph plugins
  file { '/usr/local/sbin/ceph-collector.sh':
    ensure  => file,
    mode    => '0755',
    owner   => root,
    group   => root,
    require => File['/usr/local/sbin/ceph-collect.sh'],
    source  => 'puppet:///modules/profile/muninplugins/ceph-collector.sh',
  }
  file { '/usr/local/sbin/ceph-collect.sh':
    ensure => file,
    mode   => '0755',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/profile/muninplugins/ceph-collect.sh',
  }
  
  #Install systemd services
  file { '/lib/systemd/system/cephcollectorImages.service':
    ensure => file,
    mode   => '0644',
    owner  => root,
    group  => root,
    notify => Exec['ceph-systemd-reload'],
    source => 'puppet:///modules/profile/systemd/cephcollectorImages.service',
  }
  file { '/lib/systemd/system/cephcollectorVolumes.service':
    ensure => file,
    mode   => '0644',
    owner  => root,
    group  => root,
    notify => Exec['ceph-systemd-reload'],
    source => 'puppet:///modules/profile/systemd/cephcollectorVolumes.service',
  }
  file { '/lib/systemd/system/cephcollectorRBD.service':
    ensure => file,
    mode   => '0644',
    owner  => root,
    group  => root,
    notify => Exec['ceph-systemd-reload'],
    source => 'puppet:///modules/profile/systemd/cephcollectorRBD.service',
  }

  exec { 'ceph-systemd-reload':
    command     => '/bin/systemctl daemon-reload',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    refreshonly => true,
  }

  service { 'cephcollectorRBD':
    ensure   => running,
    enable   => true,
    provider => 'systemd',
    require  => [
      File['/lib/systemd/system/cephcollectorRBD.service'],
      File['/usr/local/sbin/ceph-collector.sh'],
      Exec['ceph-systemd-reload'],
    ],
  }

  service { 'cephcollectorVolumes':
    ensure   => running,
    enable   => true,
    provider => 'systemd',
    require  => [
      File['/lib/systemd/system/cephcollectorVolumes.service'],
      File['/usr/local/sbin/ceph-collector.sh'],
      Exec['ceph-systemd-reload'],
    ],
  }

  service { 'cephcollectorImages':
    ensure   => running,
    enable   => true,
    provider => 'systemd',
    require  => [
      File['/lib/systemd/system/cephcollectorImages.service'],
      File['/usr/local/sbin/ceph-collector.sh'],
      Exec['ceph-systemd-reload'],
    ],
  }

  # Install the munin plugins
  file { '/usr/share/munin/plugins/ceph_traffic_':
    ensure => file,
    mode   => '0755',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/profile/muninplugins/ceph_traffic_',
  }
  file { '/usr/share/munin/plugins/ceph_iops_':
    ensure => file,
    mode   => '0755',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/profile/muninplugins/ceph_iops_',
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
