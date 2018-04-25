# Defines the databases used by openstack
class profile::openstack::databases {
  include ::profile::openstack::cinder::database
  include ::profile::openstack::keystone::database
  include ::profile::openstack::glance::database
}
