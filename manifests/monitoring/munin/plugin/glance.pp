# This class installs the munin-plugins for monitoring status of glance
class profile::monitoring::munin::plugin::glance {
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

  munin::plugin { 'openstack_os_images':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/openstack_os_images',
    config => [ 'user glance',
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${admin_username}",
      "env.OS_PASSWORD ${admin_pass}",
      "env.OS_AUTH_URL ${keystone_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ],
  }
}
