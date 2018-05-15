# Installs munin plugins for the nova API, if munin is enabled.
class profile::openstack::nova::munin::api {
  $installmunin = hiera('profile::munin::install', true)

  if($installmunin) {
    include ::profile::munin::plugin::nova
  }
}
