class profile::ceph::osd {
  $controllernames = join(hiera("controller::names"), ",")
  $controlleraddresses = join(hiera("controller::storage::addresses"), ",")
  
  $fsid = hiera("profile::ceph::fsid")
  $mon_key = hiera("profile::ceph::monitor_key")
  $admin_key = hiera("profile::ceph::admin_key")
  $bootstrap_osd_key = hiera("profile::ceph::osd_bootstrap_key")
  $replicas =  hiera("profile::ceph::replicas", undef)
  $journal_size =  hiera("profile::ceph::journal::size", 10000)
  
  $osds = hiera("profile::ceph::osds")
  
  class { 'ceph::repo': }
  class { 'ceph':
    fsid  => $fsid,
    mon_initial_members => $controllernames,
    mon_host            => $controlleraddresses,
    osd_pool_default_size => $replicas,
  }
  ceph_config {
    'global/osd_journal_size': value => $journal_size;
  }
  ceph::key {'client.bootstrap-osd':
    keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
    secret       => $bootstrap_osd_key,
  }

  class { '::ceph::osds':
    args => $osds,
  }   
}
