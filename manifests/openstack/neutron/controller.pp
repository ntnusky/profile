# Installs and configures the neutron service on an openstack controller node
# in the SkyHiGh architecture. This class installs both the API and the neutron
# agents.
class profile::openstack::neutron::controller {
  $service_plugins = hiera('profile::neutron::service_plugins')
  $mtu = hiera('profile::neutron::mtu', undef)
  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')
  $rabbit_ip = hiera('profile::rabbitmq::ip')

  require ::profile::openstack::repo

  include ::profile::openstack::neutron::agents
  include ::profile::openstack::neutron::api
  include ::profile::openstack::neutron::database
  include ::profile::openstack::neutron::external
  include ::profile::openstack::neutron::ipv6
  include ::profile::openstack::neutron::keepalived
  include ::profile::openstack::neutron::services
  include ::profile::openstack::neutron::sudo
  include ::profile::openstack::neutron::tenant

  class { '::neutron':
    verbose                 => true,
    core_plugin             => 'ml2',
    allow_overlapping_ips   => true,
    service_plugins         => $service_plugins,
    dhcp_agents_per_network => 2,
    rabbit_password         => $rabbit_pass,
    rabbit_user             => $rabbit_user,
    rabbit_host             => $rabbit_ip,
    global_physnet_mtu      => $mtu,
  }
}
