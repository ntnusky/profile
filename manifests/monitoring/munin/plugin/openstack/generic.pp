# This define sets up a generic openstack-plugin for munin.
define profile::monitoring::munin::plugin::openstack::generic (
  $plugin_user = 'root',
) {
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

  munin::plugin { $name:
    ensure => present,
    source => "puppet:///modules/profile/muninplugins/${name}",
    config => [ "user ${plugin_user}",
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_username}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${keystone_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }
}
