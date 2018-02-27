# Installs and configures Placement API
class profile::openstack::nova::endpoint::placement {
  $nova_password = hiera('profile::nova::keystone::password')
  $region = hiera('profile::region')

  $nova_public_ip = hiera('profile::api::nova::public::ip')
  $nova_admin_ip = hiera('profile::api::nova::admin::ip')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')

  $admin_endpoint = hiera('profile::openstack::endpoint::admin', false)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', false)
  $public_endpoint = hiera('profile::openstack::endpoint::public', false)

  $nova_admin    = pick($admin_endpoint, "http://${nova_admin_ip}")
  $nova_internal = pick($internal_endpoint, "http://${nova_admin_ip}")
  $nova_public   = pick($public_endpoint, "http://${nova_public_ip}")

  $placement_password = hiera('profile::placement::keystone::password')

  class { '::nova::keystone::auth_placement':
    password     => $placement_password,
    public_url   => "${nova_public}:8778/placement",
    internal_url => "${nova_internal}:8778/placement",
    admin_url    => "${nova_admin}:8778/placement",
    region       => $region,
  }
}
