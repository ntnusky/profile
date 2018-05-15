# Installs the nova vnc proxy
class profile::openstack::nova::vncproxy {
  require ::profile::openstack::repo

  class { '::nova::vncproxy':
    enabled => true,
  }
}
