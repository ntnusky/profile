# This class installs the neutron agents needed on a compute-node.
class profile::openstack::neutron::compute {
  require ::profile::openstack::repo

  require ::profile::openstack::neutron::tenant
}
