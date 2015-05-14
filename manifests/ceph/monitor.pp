class profile::ceph::monitor {
  $controllernames = join(hiera("controller::names"), ",")
  $controlleraddresses = join(hiera("controller::storage::addresses"), ",")
  
  $fsid = hiera("profile::ceph::fsid")
  $mon_key = hiera("profile::ceph::monitor_key")
  $admin_key = hiera("profile::ceph::admin_key")
  $bootstrap_osd_key = hiera("profile::ceph::osd_bootstrap_key")
  $replicas =  hiera("profile::ceph::replicas", undef)
  
  anchor { "profile::ceph::monitor::begin" : } ->
  class { 'ceph::repo': } ->
  class { 'ceph':
    fsid  => $fsid,
    mon_initial_members => $controllernames,
    mon_host            => $controlleraddresses,
    osd_pool_default_size => $replicas,
    before              => Anchor['profile::ceph::monitor::end'],
    require             => Anchor['profile::ceph::monitor::begin'],
  }
  ceph::mon { $::hostname:
    key => $mon_key,
    before              => Anchor['profile::ceph::monitor::end'],
    require             => Anchor['profile::ceph::monitor::begin'],
  }
  Ceph::Key {
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
  }
  ceph::key { 'client.admin':
    secret  => $admin_key,
    cap_mon => 'allow *',
    cap_osd => 'allow *',
    cap_mds => 'allow',
    before              => Anchor['profile::ceph::monitor::end'],
    require             => Anchor['profile::ceph::monitor::begin'],
  }
  ceph::key { 'client.bootstrap-osd':
    secret  => $bootstrap_osd_key,
    cap_mon => 'allow profile bootstrap-osd',
    before              => Anchor['profile::ceph::monitor::end'],
    require             => Anchor['profile::ceph::monitor::begin'],
  }
  anchor { "profile::ceph::monitor::end" : }
}
