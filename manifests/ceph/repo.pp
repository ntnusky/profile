# Abstraction for the ceph::repo class
class profile::ceph::repo {

  class { '::ceph::repo':
    enable_epel => false,
    enable_sig  => true,
  }
}
