# This class installs the munin-plugins for monitoring status of glance
class profile::monitoring::munin::plugin::openstack::glance {
  $plugins = [
    'openstack_os_images',
  ]

  ::profile::monitoring::munin::plugin::openstack::generic { $plugins:
    keystone_user => 'admin',
    plugin_user   => 'glance',
  }
}
