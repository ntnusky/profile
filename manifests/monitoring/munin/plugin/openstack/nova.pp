# This class installs the munin plugins which monitors openstack usage
# variables. Should be installed on the openstack controllers.
class profile::monitoring::munin::plugin::openstack::nova {
  $plugins = [
    'openstack_cpu',
    'openstack_disk',
    'openstack_hypervisors',
    'openstack_os_instances',
    'openstack_server_status',
    'openstack_ram',
  ]

  ::profile::monitoring::munin::plugin::openstack::generic { $plugins:
    plugin_user => 'nova',
  }
}
