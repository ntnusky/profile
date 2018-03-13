# Install and configure ceph-mon
class profile::ceph::monitor {
  $mon_key = hiera('profile::ceph::monitor_key')
  $mgr_key = hiera('profile::ceph::mgr_key')

  $installmunin = hiera('profile::munin::install', true)
  if($installmunin) {
    include ::profile::munin::plugin::ceph
  }

  $installsensu = hiera('profile::sensu::install', true)
  if ($installsensu) {
    include ::profile::sensu::plugin::ceph
  }

  require ::profile::ceph::base
  include ::profile::ceph::keys::admin
  include ::profile::ceph::keys::bootstraposd

  ceph::mgr { $::hostname :
    key        => $mgr_key,
    inject_key => true,
  }

  ceph::mon { $::hostname:
    key    => $mon_key,
  }
}
