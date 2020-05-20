# This class installs the munin plugins which monitors openstack magnum
class profile::monitoring::munin::plugin::openstack::magnum {
  $plugins = [
    'openstack_magnum_clusters',
    'openstack_magnum_nodes',
    'openstack_magnum_templates',
  ]

  ::profile::monitoring::munin::plugin::openstack::generic { $plugins:
    plugin_user => 'magnum',
  }
}
