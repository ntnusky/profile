# This class installs the neutron agents needed on a compute-node.
class profile::openstack::neutronagent {
  $password = hiera('profile::mysql::neutronpass')
  $keystone_ip = hiera('profile::api::keystone::public::ip')
  $mysql_ip = hiera('profile::mysql::ip')
  $neutron_pass = hiera('profile::neutron::keystone::password')
  $rabbit_ip = hiera('profile::rabbitmq::ip')
  $mtu = hiera('profile::neutron::mtu', undef)

  $region = hiera('profile::region')
  $admin_ip = hiera('profile::api::neutron::admin::ip')
  $public_ip = hiera('profile::api::neutron::public::ip')
  $service_plugins = hiera('profile::neutron::service_plugins')

  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')

  $_tenant_if = hiera('profile::interfaces::tenant')

  $database_connection = "mysql://neutron:${password}@${mysql_ip}/neutron"

  require ::profile::openstack::repo
  include ::profile::openstack::neutron::sudo
  include ::profile::openstack::neutron::tenant

  anchor{ 'profile::openstack::neutronagent::begin' : }
  anchor{ 'profile::openstack::neutronagent::end' : }

  class { '::neutron':
    core_plugin           => 'ml2',
    allow_overlapping_ips => true,
    service_plugins       => $service_plugins,
    before                => Anchor['profile::openstack::neutronagent::end'],
    require               => Anchor['profile::openstack::neutronagent::begin'],
    rabbit_password       => $rabbit_pass,
    rabbit_user           => $rabbit_user,
    rabbit_host           => $rabbit_ip,
    global_physnet_mtu    => $mtu,
  }

  class { '::neutron::server':
    enabled             => false,
    sync_db             => false,
    password            => $neutron_pass,
    auth_uri            => "http://${keystone_ip}:5000/",
    database_connection => $database_connection,
    before              => Anchor['profile::openstack::neutronagent::end'],
    require             => Anchor['profile::openstack::neutronagent::begin'],
  }

  neutron_l3_agent_config {
    'AGENT/extensions': value => 'fwaas';
  }
}
