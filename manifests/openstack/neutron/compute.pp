# This class installs the neutron agents needed on a compute-node.
class profile::openstack::neutron::compute {
  $mtu = hiera('profile::neutron::mtu', undef)
  $rabbit_ip = hiera('profile::rabbitmq::ip')
  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')

  require ::profile::openstack::repo

  include ::profile::openstack::neutron::sudo
  include ::profile::openstack::neutron::tenant

  class { '::neutron':
    core_plugin           => 'ml2',
    allow_overlapping_ips => true,
    rabbit_password       => $rabbit_pass,
    rabbit_user           => $rabbit_user,
    rabbit_host           => $rabbit_ip,
    global_physnet_mtu    => $mtu,
  }

  neutron_l3_agent_config {
    'AGENT/extensions': value => 'fwaas';
  }
}
