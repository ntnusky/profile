# Configures the keystone endpoint
class profile::openstack::keystone::endpoint {
  $region = hiera('profile::region')
  $admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $public_ip = hiera('profile::api::keystone::public::ip', '127.0.0.1')

  $admin_endpoint = hiera('profile::openstack::endpoint::admin',
      "http://${admin_ip}")
  $internal_endpoint = hiera('profile::openstack::endpoint::internal',
      "http://${admin_ip}")
  $public_endpoint = hiera('profile::openstack::endpoint::public',
      "http://${public_ip}")

  # We need to define the endpoints on the keystone hosts, so include the other
  # endpoints here.
  include ::profile::openstack::glance::endpoint

  class { '::keystone::endpoint':
    public_url   => "${public_endpoint}:5000",
    admin_url    => "${admin_endpoint}:35357",
    internal_url => "${internal_endpoint}:5000",
    version      => 'v3',
    region       => $region,
    require      => Class['::keystone'],
  }
}
