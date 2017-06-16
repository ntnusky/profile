# Installs munin plugins for the nova API, if munin is enabled.
class profile::openstack::nova::munin::api {
  $installMunin = hiera('profile::munin::install', true)

  if($installMunin) {
    include ::profile::munin::plugin::nova
  }
}
