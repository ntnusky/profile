# This class installs the munin plugins which monitors openstack usage
# variables. Should be installed on the openstack compute nodes.
class profile::monitoring::munin::plugin::openstack::compute {
  $plugins = [
    'compute_cpu',
    'compute_disk',
    'compute_ram',
    'compute_vms',
  ]

  ::profile::monitoring::munin::plugin::openstack::generic { $plugins:
    keystone_user => 'admin',
    plugin_user   => 'nova',
  }
}
