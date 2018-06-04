# Installs the lbaas agents on a neutron network node
class profile::openstack::neutron::lbaas {
  class { 'neutron::services::lbaas::haproxy' : }
  class { 'neutron::agents::lbaas' : }
}
