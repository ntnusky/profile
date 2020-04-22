# This class installs the munin-plugins for monitoring status of glance
#
# The class is simply a redirect to the new class with a new name. This class
# will be removed in the future!
class profile::monitoring::munin::plugin::glance {
  contain ::profile::monitoring::munin::plugin::openstack::glance
}
