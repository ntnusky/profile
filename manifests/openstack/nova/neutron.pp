# Configures nova to use neutron for networking.
class profile::openstack::nova::neutron {
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $neutron_admin_ip = hiera('profile::api::neutron::admin::ip')
  $neutron_password = hiera('profile::neutron::keystone::password')
  $region = hiera('profile::region')

  require ::profile::openstack::repo

  class { 'nova::network::neutron':
    neutron_region_name   => $region,
    neutron_password      => $neutron_password,
    neutron_url           => "http://${neutron_admin_ip}:9696",
    neutron_auth_url      => "http://${keystone_admin_ip}:35357/v3",
    vif_plugging_is_fatal => false,
    vif_plugging_timeout  => '0',
  }
}
