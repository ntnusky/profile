# Installs munin plugins, if munin is enabled.
class profile::openstack::nova::munin::compute {
  $installMunin = hiera('profile::munin::install', true)

  if($installMunin) {
    include ::profile::munin::plugin::compute
  }
}

