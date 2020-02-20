# This class installs munin-plugins for our keystone-nodes
class profile::monitoring::munin::plugin::openstack::keystone {
  $plugins = [
    'openstack_projects',
  ]

  ::profile::monitoring::munin::plugin::openstack::generic { $plugins:
    keystone_user => 'admin',
    plugin_user   => 'keystone',
  }
}
