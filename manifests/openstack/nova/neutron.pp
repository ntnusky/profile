# Configures nova to use neutron for networking.
class profile::openstack::nova::neutron {
  $neutron_password = hiera('profile::neutron::keystone::password')
  $region = hiera('profile::region')

  $internal_endpoint = hiera('profile::openstack::endpoint::internal', undef)

  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")

  $neutron_admin_ip = hiera('profile::api::neutron::admin::ip', '127.0.0.1')
  $neutron_internal = pick($internal_endpoint, "http://${neutron_admin_ip}")

  require ::profile::openstack::repo

  class { '::nova::network::neutron':
    neutron_region_name   => $region,
    neutron_password      => $neutron_password,
    neutron_url           => "${neutron_internal}:9696",
    neutron_auth_url      => "${keystone_internal}:35357/v3",
    vif_plugging_is_fatal => false,
    vif_plugging_timeout  => '0',
  }
}
