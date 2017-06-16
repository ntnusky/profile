# Installs various nova services.
class profile::openstack::nova::services {
  require ::profile::openstack::repo
  require ::profile::openstack::nova::base
  contain ::profile::openstack::nova::neutron
  contain ::profile::openstack::nova::vncproxy

  class { [
    'nova::scheduler',
    'nova::cert',
    'nova::consoleauth',
    'nova::conductor'
  ]:
    enabled => true,
  }
}
