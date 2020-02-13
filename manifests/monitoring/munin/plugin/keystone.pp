# This class installs munin-plugins for our keystone-nodes
class profile::monitoring::munin::plugin::keystone {
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

  munin::plugin { 'openstack_projects':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_projects',
    config => [ 'user keystone',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_username}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${keystone_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }
}
