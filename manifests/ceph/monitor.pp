class profile::ceph::monitor {
  $controllernames = join(hiera("controller::names"), ",")
  $controlleraddresses = join(hiera("controller::storage::addresses"), ",")
  
  $fsid = hiera("profile::ceph::fsid")
  $mon_key = hiera("profile::ceph::monitor_key")
  $admin_key = hiera("profile::ceph::admin_key")
  $bootstrap_osd_key = hiera("profile::ceph::osd_bootstrap_key")
  $replicas =  hiera("profile::ceph::replicas", undef)
  $journal_size =  hiera("profile::ceph::journal::size", 10000)
  
  class { 'ceph::repo': }->
  class { 'ceph':
    fsid  => $fsid,
    mon_initial_members => $controllernames,
    mon_host            => $controlleraddresses,
    osd_pool_default_size => $replicas,
  }->
  ceph_config {
    'global/osd_journal_size': value => $journal_size;
  }->
  ceph::mon { $::hostname:
    key => $mon_key,
  }->
  Ceph::Key {
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
  }->
  ceph::key { 'client.admin':
    secret  => $admin_key,
    cap_mon => 'allow *',
    cap_osd => 'allow *',
    cap_mds => 'allow',
  }->
  ceph::key { 'client.bootstrap-osd':
    secret  => $bootstrap_osd_key,
    cap_mon => 'allow profile bootstrap-osd',
  }->
  anchor{'profile::ceph::monitor::end':}
}
