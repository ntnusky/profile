# Configures the keystone endpoint
class profile::openstack::keystone::endpoint {
  $region = hiera('profile::region')
  $admin_ip = hiera('profile::api::keystone::admin::ip')
  $public_ip = hiera('profile::api::keystone::public::ip')

  $admin_endpoint = hiera('profile::keystone::endpoint::admin',
      "http://${admin_ip}")
  $internal_endpoint = hiera('profile::keystone::endpoint::internal',
      "http://${admin_ip}")
  $public_endpoint = hiera('profile::keystone::endpoint::public',
      "http://${public_ip}")

  class { '::keystone::endpoint':
    public_url   => "${public_endpoint}:5000",
    admin_url    => "${admin_endpoint}:35357",
    internal_url => "${internal_endpoint}:5000",
    version      => 'v3',
    region       => $region,
    require      => Class['::keystone'],
  }
}
