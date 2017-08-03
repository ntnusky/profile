# Installs and configures Placement API
class profile::openstack::nova::placement {
  $placement_password = hiera('profile::placement::keystone::password')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $region = hiera('profile::region')
  $nova_admin_ip = hiera('profile::api::nova::admin::ip')

  class { '::nova::placement':
    password       => $placement_password,
    auth_url       => "http://${keystone_admin_ip}:35357/v3",
    os_region_name => $region,
  }

  class { '::nova::keystone::auth_placement':
    password     => $placement_password,
    public_url   => "http://${nova_admin_ip}:8770/placement",
    internal_url => "http://${nova_admin_ip}:8770/placement",
    admin_url    => "http://${nova_admin_ip}:8770/placement",
  }

  class { '::nova::wsgi::apache_placement':
    servername => $nova_admin_ip,
    api_port   => 8770,
    ssl        => false,
  }
}
