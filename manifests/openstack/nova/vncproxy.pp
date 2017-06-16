# Installs the nova vnc proxy
class profile::openstack::nova::vncproxy {
  $vnc_proxy_ip = hiera('nova::vncproxy::host')

  require ::profile::openstack::repo

  class { 'nova::vncproxy':
    host    => $vnc_proxy_ip,
    enabled => true,
  }
}
