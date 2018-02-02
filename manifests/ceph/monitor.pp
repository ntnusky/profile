# Install and configure ceph-mon
class profile::ceph::monitor {
  $controllernames = join(hiera('controller::names'), ',')
  $controlleraddresses = join(hiera('controller::storage::addresses'), ',')

  $fsid = hiera('profile::ceph::fsid')
  $mon_key = hiera('profile::ceph::monitor_key')
  $mgr_key = hiera('profile::ceph::mgr_key')
  $admin_key = hiera('profile::ceph::admin_key')
  $bootstrap_osd_key = hiera('profile::ceph::osd_bootstrap_key')
  $replicas =  hiera('profile::ceph::replicas', undef)
  $journal_size =  hiera('profile::ceph::journal::size', 10000)

  $installMunin = hiera('profile::munin::install', true)
  if($installMunin) {
    include ::profile::munin::plugin::ceph
  }

  $installSensu = hiera('profile::sensu::install', true)
  if ($installSensu) {
    include ::profile::sensu::plugin::ceph
  }

  class { 'ceph::repo': }->
  class { 'ceph':
    fsid                  => $fsid,
    mon_initial_members   => $controllernames,
    mon_host              => $controlleraddresses,
    osd_pool_default_size => $replicas,
    before                => Anchor['profile::ceph::monitor::end']
  }
  ceph::mgr { $::hostname :
    key        => $mgr_key,
    inject_key => true,
  }
  ceph_config {
    'global/osd_journal_size': value => $journal_size;
  }
  ceph::mon { $::hostname:
    key    => $mon_key,
    before => Anchor['profile::ceph::monitor::end']
  }
  Ceph::Key {
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
    before         => Anchor['profile::ceph::monitor::end']
  }
  ceph::key { 'client.admin':
    secret  => $admin_key,
    cap_mon => 'allow *',
    cap_osd => 'allow *',
    cap_mds => 'allow',
    cap_mgr => 'allow *',
    before  => Anchor['profile::ceph::monitor::end']
  }
  ceph::key { 'client.bootstrap-osd':
    secret  => $bootstrap_osd_key,
    cap_mon => 'allow profile bootstrap-osd',
    before  => Anchor['profile::ceph::monitor::end']
  }
  anchor{'profile::ceph::monitor::end':}
}
