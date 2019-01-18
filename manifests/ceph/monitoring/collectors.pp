# Install scripts to collect metrics from ceph
class profile::ceph::monitoring::collectors {
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
}
