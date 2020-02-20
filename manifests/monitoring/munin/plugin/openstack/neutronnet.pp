# This class installs munin-plugins for our neutronnet nodes.
class profile::monitoring::munin::plugin::openstack::neutronnet {
  ::profile::monitoring::munin::plugin::openstack::generic {
      'openstack_neutron_nstypes':
    plugin_user   => 'neutron',
  }
}
