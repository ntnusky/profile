# This class installs the munin plugins which monitors openstack usage
# variables. Should be installed on the openstack controllers.
class profile::monitoring::munin::plugin::nova {
  include ::ntnuopenstack::clients

  $keystone_location = lookup('ntnuopenstack::keystone::endpoint::internal', {
    'value_type' => Stdlib::Httpurl,
  })
  $keystone_url = "${keystone_location}:5000/v3"

  $admin_username = lookup('ntnuopenstack::keystone::admin_username', {
    'value_type'    => String,
    'default_value' => 'admin',
  })
  $admin_pass = lookup('ntnuopenstack::keystone::admin_password', {
    'value_type' => String,
  })

  munin::plugin { 'openstack_cpu':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_cpu',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_username}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${keystone_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'openstack_disk':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_disk',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_username}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${keystone_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'openstack_hypervisors':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_hypervisors',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_username}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${keystone_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'openstack_os_instances':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_os_instances',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_username}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${keystone_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'openstack_server_status':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_server_status',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_username}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${keystone_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'openstack_ram':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_ram',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_username}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${keystone_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }
}
