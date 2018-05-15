# Installs and configures Placement API
class profile::openstack::nova::api::placement {
  $placement_password = hiera('profile::placement::keystone::password')
  $region = hiera('profile::region')
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)

  $admin_endpoint = hiera('profile::openstack::endpoint::admin', undef)
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")

  if($confhaproxy) {
    contain ::profile::openstack::glance::haproxy::backend::placement
  }

  class { '::nova::placement':
    password       => $placement_password,
    auth_url       => "${keystone_admin}:35357/v3",
    os_region_name => $region,
  }

  class { '::nova::wsgi::apache_placement':
    api_port   => 8778,
    ssl        => false,
  }
}
