# This class installs the openstack clients.
class profile::openstack::clients {
  require ::profile::openstack::repo

  include ::keystone::client
  include ::cinder::client
  include ::nova::client
  include ::neutron::client
  include ::glance::client
}
