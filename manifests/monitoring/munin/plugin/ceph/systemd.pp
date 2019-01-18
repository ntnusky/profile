# This class configures the systemd services collecting metrics from ceph
class profile::monitoring::munin::plugin::ceph::systemd {
  require ::profile::ceph::monitoring::collectors
  require ::profile::systemd::reload

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
}
