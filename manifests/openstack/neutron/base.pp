# Installs the base neutron services.
class profile::openstack::neutron::base {
  $service_plugins = hiera('profile::neutron::service_plugins')
  $mtu = hiera('profile::neutron::mtu', undef)
  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')
  $rabbit_ip = hiera('profile::rabbitmq::ip')

  require ::profile::openstack::repo
  include ::profile::openstack::neutron::sudo

  class { '::neutron':
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
