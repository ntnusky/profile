# Installs the nova vnc proxy
class profile::openstack::nova::vncproxy {
  include ::profile::openstack::nova::firewall::vncproxy
  include ::profile::openstack::nova::haproxy::backend::vnc
  require ::profile::openstack::repo

  class { '::nova::vncproxy':
    enabled => true,
  }
}
