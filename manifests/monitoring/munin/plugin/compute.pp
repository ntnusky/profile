# This class installs the munin plugins which monitors openstack usage
# variables. Should be installed on the openstack compute nodes.
class profile::monitoring::munin::plugin::compute {
  include ::ntnuopenstack::clients

  $internal_endpoint  = hiera('ntnuopenstack::endpoint::admin', undef)
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")

  $admin_token = hiera('ntnuopenstack::keystone::admin_token')
  $admin_pass = hiera('ntnuopenstack::keystone::admin_password')
  $admin_url = "${keystone_internal}:5000/v3"

  munin::plugin { 'compute_cpu':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/compute_cpu',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }
  munin::plugin { 'compute_disk':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/compute_disk',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }
  munin::plugin { 'compute_ram':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/compute_ram',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }
  munin::plugin { 'compute_vms':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/compute_vms',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }
}
