# This class installs the munin plugins which monitors openstack octavia
class profile::monitoring::munin::plugin::openstack::octavia {
  $plugins = [
    'openstack_octavia_amphora_statuses',
    'openstack_octavia_balancer_statuses',
  ]

  ::profile::monitoring::munin::plugin::openstack::generic { $plugins:
    plugin_user => 'octavia',
  }
}
