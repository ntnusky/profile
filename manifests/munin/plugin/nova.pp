# This class installs the munin plugins which monitors openstack usage
# variables. Should be installed on the openstack controllers.
class profile::munin::plugin::nova {
  $admin_ip = hiera('profile::api::keystone::admin::ip')
  $admin_token = hiera('profile::keystone::admin_token')
  $admin_pass = hiera('profile::keystone::admin_password')
  $admin_url = "http://${admin_ip}:5000/v3"

  munin::plugin { 'openstack_projects':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_projects',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'openstack_server_status':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_server_status',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'openstack_floatingip':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_floatingip',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'openstack_cpu':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_cpu',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'openstack_disk':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_disk',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'openstack_hypervisors':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_hypervisors',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'openstack_ram':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_ram',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'nova_cpu':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/nova_cpu',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'nova_ram':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/nova_ram',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }

  munin::plugin { 'nova_disk':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/nova_disk',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_token}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }
}
