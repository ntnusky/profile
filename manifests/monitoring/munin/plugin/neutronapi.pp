# This class installs relevant munin-plugins for our neutronapi-nodes
#
# The class is simply a redirect to the new class with a new name. This class
# will be removed in the future!
class profile::monitoring::munin::plugin::neutronapi {
  contain ::profile::monitoring::munin::plugin::openstack::neutronapi
}
