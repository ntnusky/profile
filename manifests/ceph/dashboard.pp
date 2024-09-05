# Installs the ceph dashboard packages
class profile::ceph::dashboard {
  package { 'ceph-mgr-dashboard':
    ensure => present,
  }
}
