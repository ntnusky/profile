# Installs and configures a ceph storage node, and adds osd's according to the
# hiera 'profile::ceph::osds' key.
class profile::ceph::osd {
  $bootstrap_osd_key = hiera('profile::ceph::osd_bootstrap_key')

  $osds = hiera('profile::ceph::osds')

  require ::profile::ceph::base

  ceph::key {'client.bootstrap-osd':
    keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
    secret       => $bootstrap_osd_key,
  }

  class { '::ceph::osds':
    args => $osds,
  }
}
