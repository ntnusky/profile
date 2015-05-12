class profile::ceph::osd {
  $controllernames = hiera("controllernames")
  $controlleraddresses = hiera("controlleraddresses")
  
  $fsid = hiera("profile::ceph::fsid")
  $mon_key = hiera("profile::ceph::monitor_key")
  $admin_key = hiera("profile::ceph::admin_key")
  $bootstrap_osd_key = hiera("profile::ceph::osd_bootstrap_key")
  
  $disks = hiera("profile::ceph::osds")
  $journals = hiera("profile::ceph::journals", false)
  
  class { 'ceph::repo': }
  class { 'ceph':
    fsid  => $fsid,
    mon_initial_members => $controllernames,
    mon_host            => $controlleraddresses,
  }
  ceph::key {'client.bootstrap-osd':
    keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
    secret       => $bootstrap_osd_key,
  }
   
  if($journals) {
    fail("Currently not implemented support for ceph journals")
  } else {
    ceph::osd {
      $disks :
    }
  }
}
