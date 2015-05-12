class profile::ceph::monitor {
  $controllernames = join(hiera("controllernames"), ",")
  $controlleraddresses = join(hiera("controlleraddresses"), ",")
  
  $fsid = hiera("profile::ceph::fsid")
  $mon_key = hiera("profile::ceph::monitor_key")
  $admin_key = hiera("profile::ceph::admin_key")
  $bootstrap_osd_key = hiera("profile::ceph::osd_bootstrap_key")
  
  class { 'ceph::repo': }
  class { 'ceph':
    fsid  => $fsid,
    mon_initial_members => $controllernames,
    mon_host            => $controlleraddresses,
  }
  ceph::mon { $::hostname:
    key => $mon_key,
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
  }
  ceph::key { 'client.bootstrap-osd':
    secret  => $bootstrap_osd_key,
    cap_mon => 'allow profile bootstrap-osd',
  }
}
