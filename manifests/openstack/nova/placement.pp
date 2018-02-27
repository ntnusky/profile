# Installs and configures Placement API
class profile::openstack::nova::placement {
  $placement_password = hiera('profile::placement::keystone::password')
  $region = hiera('profile::region')
  $nova_admin_ip = hiera('profile::api::nova::admin::ip')

  $admin_endpoint = hiera('profile::openstack::endpoint::admin', false)
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")

  contain ::profile::openstack::nova::endpoint::placement

  if($confhaproxy) {
    contain ::profile::openstack::glance::haproxy::backend::placement
  }

  class { '::nova::placement':
    password       => $placement_password,
    auth_url       => "${keystone_admin}:35357/v3",
    os_region_name => $region,
  }

  class { '::nova::wsgi::apache_placement':
    servername => $nova_admin_ip,
    api_port   => 8778,
    ssl        => false,
  }
}
