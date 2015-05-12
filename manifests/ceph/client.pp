class profile::ceph::monitor {
  $controllernames = hiera("controllernames")
  $controlleraddresses = hiera("controlleraddresses")
  
  $fsid = hiera("profile::ceph::fsid")
  $admin_key = hiera("profile::ceph::admin_key")
  
  class { 'ceph::repo': }
  class { 'ceph':
    fsid                => $fsid,
    mon_initial_members => $controllernames,
    mon_host            => $controlleraddresses,
  }
  ceph::key { 'client.admin':
    secret              => $admin_key,
  }
}
