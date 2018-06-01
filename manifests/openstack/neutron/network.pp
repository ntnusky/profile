# Installs and configures a neutron network node
class profile::openstack::neutron::network {
  require ::profile::openstack::repo

  contain ::profile::openstack::neutron::agents
  contain ::profile::openstack::neutron::external
  contain ::profile::openstack::neutron::firewall::l3agent
  contain ::profile::openstack::neutron::ipv6
  contain ::profile::openstack::neutron::lbaas
  contain ::profile::openstack::neutron::services
  contain ::profile::openstack::neutron::tenant
}
