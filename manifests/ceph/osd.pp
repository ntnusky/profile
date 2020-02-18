# Installs and configures a ceph storage node, and adds osd's according to the
# hiera 'profile::ceph::osds' key.
class profile::ceph::osd {
  $bootstrap_osd_key = lookup('profile::ceph::osd_bootstrap_key', String)
  $memory_target = lookup('profile::ceph::osd::memory::target', {
    'default_value' => 1610612736,
    'value_type'    => Integer,
  })

  $osds = lookup('profile::ceph::osds', Hash)

  require ::profile::ceph::base
  include ::profile::ceph::firewall::daemons
  include ::profile::ceph::firewall::clusternet

  ceph::key {'client.bootstrap-osd':
    keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
    secret       => $bootstrap_osd_key,
  }

  class { '::ceph::osds':
    args => $osds,
  }

  ceph_config {
    'global/osd_memory_target': value => $memory_target;
  }
}
