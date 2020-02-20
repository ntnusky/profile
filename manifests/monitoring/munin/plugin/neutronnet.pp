# This class installs munin-plugins for our neutronnet nodes.
#
# The class is simply a redirect to the new class with a new name. This class
# will be removed in the future!
class profile::monitoring::munin::plugin::neutronnet {
  contain ::profile::monitoring::munin::plugin::openstack::neutronnet
}
