# Installs munin plugins, if munin is enabled.
class profile::openstack::nova::munin::compute {
  $installmunin = hiera('profile::munin::install', true)

  if($installmunin) {
    include ::profile::monitoring::munin::plugin::compute
  }
}

