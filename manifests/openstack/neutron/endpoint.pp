# Configures the neutron endpoint in keystone
class profile::openstack::neutron::endpoint {
  # Retrieve service IP Addresses
  $neutron_admin_ip   = hiera('profile::api::neutron::admin::ip', '127.0.0.1')
  $neutron_public_ip  = hiera('profile::api::neutron::public::ip', '127.0.0.1')

  # Retrieve api urls, if they exist. 
  $admin_endpoint    = hiera('profile::openstack::endpoint::admin', undef)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', undef)
  $public_endpoint   = hiera('profile::openstack::endpoint::public', undef)

  # Determine which endpoint to use
  $neutron_admin     = pick($admin_endpoint, "http://${neutron_admin_ip}")
  $neutron_internal  = pick($internal_endpoint, "http://${neutron_admin_ip}")
  $neutron_public    = pick($public_endpoint, "http://${neutron_public_ip}")

  # Openstack settings
  $neutron_password = hiera('profile::neutron::keystone::password')
  $region = hiera('profile::region')

  # Configure the neutron API endpoint in keystone
  class { '::neutron::keystone::auth':
    password     => $neutron_password,
    public_url   => "${neutron_public}:9696",
    internal_url => "${neutron_internal}:9696",
    admin_url    => "${neutron_admin}:9696",
    region       => $region,
  }
}
