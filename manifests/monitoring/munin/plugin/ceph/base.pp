# Installs the base-plugins for ceph. Other classes link to these scripts to
# actually monitor a ceph pool.
class profile::monitoring::munin::plugin::ceph::base {
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
}
