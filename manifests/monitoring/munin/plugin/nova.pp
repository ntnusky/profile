# This class installs the munin plugins which monitors openstack usage
# variables. Should be installed on the openstack controllers.
#
# The class is simply a redirect to the new class with a new name. This class
# will be removed in the future!
class profile::monitoring::munin::plugin::nova {
  contain ::profile::monitoring::munin::plugin::openstack::nova
}
