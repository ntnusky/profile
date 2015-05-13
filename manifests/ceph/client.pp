class profile::ceph::client {
  $controllernames = join(hiera("controller::names"), ",")
  $controlleraddresses = join(hiera("controller::storage::addresses"), ",")
  
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
