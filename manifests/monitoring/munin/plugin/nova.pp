# This class installs the munin plugins which monitors openstack usage
# variables. Should be installed on the openstack controllers.
class profile::monitoring::munin::plugin::nova {
  include ::ntnuopenstack::clients

  $internal_endpoint  = hiera('ntnuopenstack::endpoint::admin', undef)
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")

  $admin_username = hiera('ntnuopenstack::keystone::admin_username', 'admin')
  $admin_pass = hiera('ntnuopenstack::keystone::admin_password')
  $admin_url = "${keystone_internal}:5000/v3"

  $externalnets = lookup('ntnuopenstack::neutron::networks::external', {
    'value_type' => Hash,
  })

  $externalnets.each | $key, $data | {
    $net = $data['name']
    munin::plugin { "openstack_ipuse_${net}":
      ensure => present,
      source => 'puppet:///modules/profile/muninplugins/openstack_ipuse_',
      config => [ 'user nova',
        'env.OS_PROJECT_NAME admin',
        "env.OS_USERNAME ${admin_username}",
        "env.OS_PASSWORD ${admin_pass}",
        "env.OS_AUTH_URL ${admin_url}",
        'env.OS_IDENTITY_API_VERSION 3',
      ],
    }
  }

  $externalnames = $externalnets.map | $key, $data | { $data['name'] }
  $externals = join($externalnames, ' ')

  munin::plugin { 'openstack_ipuse':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_ipuse',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_username}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
      "env.EXTERNALS ${externals}",
    ],
  }

  munin::plugin { 'openstack_projects':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_projects',
    config => [ 'user nova',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_username}",
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
      "env.OS_USERNAME ${admin_username}",
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
      "env.OS_USERNAME ${admin_username}",
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
      "env.OS_USERNAME ${admin_username}",
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
      "env.OS_USERNAME ${admin_username}",
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
      "env.OS_USERNAME ${admin_username}",
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
      "env.OS_USERNAME ${admin_username}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${admin_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }
}
