# Installs and configures a ceph storage node, and adds osd's according to the
# hiera 'profile::ceph::osds' key.
class profile::ceph::osd {
  $osds = hiera('profile::ceph::osds')

  require ::profile::ceph::base
  require ::profile::ceph::keys::admin
  require ::profile::ceph::keys::bootstraposd

  class { '::ceph::osds':
    args => $osds,
  }
}
