# This class installs the munin plugins which monitors openstack usage
# variables. Should be installed on the openstack compute nodes.
class profile::munin::plugin::compute {
  $admin_ip = hiera('profile::api::keystone::admin::ip')
  $admin_token = hiera('profile::keystone::admin_token')
  $admin_pass = hiera('profile::keystone::admin_password')
  $admin_url = "http://${admin_ip}:5000/v2.0/"

  munin::plugin { 'compute_cpu':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/compute_cpu',
    config => [ 'user nova',
      'env.OS_TENANT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
    ],
  }
  munin::plugin { 'compute_disk':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/compute_disk',
    config => [ 'user nova',
      'env.OS_TENANT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
    ],
  }
  munin::plugin { 'compute_ram':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/compute_ram',
    config => [ 'user nova',
      'env.OS_TENANT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
    ],
  }
  munin::plugin { 'compute_vms':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/compute_vms',
    config => [ 'user nova',
      'env.OS_TENANT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
    ],
  }
}
