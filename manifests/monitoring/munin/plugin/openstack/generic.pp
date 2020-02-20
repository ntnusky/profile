# This define sets up a generic openstack-plugin for munin.
define profile::monitoring::munin::plugin::openstack::generic (
  $keystone_user = undef,
  $plugin_extra_config = [],
  $plugin_user = 'root',
  $plugin_file = $name,
) {
  include ::ntnuopenstack::clients

  $generic_config = [
    "user ${plugin_user}",
  ]

  if($keystone_user) {
    $keystone_location = lookup('ntnuopenstack::keystone::endpoint::internal', {
      'value_type' => Stdlib::Httpurl,
    })
    $keystone_url = "${keystone_location}:5000/v3"

    if($keystone_user == 'admin') {
      $keystone_username = lookup('ntnuopenstack::keystone::admin_username', {
        'value_type'    => String,
        'default_value' => 'admin',
      })
      $keystone_pass = lookup('ntnuopenstack::keystone::admin_password', {
        'value_type' => String,
      })
    } else {
      $keystone_username = $keystone_user
      $keystone_pass = lookup(
        "ntnuopenstack::${keystone_user}::keystone::password", {
          'value_type' => String,
        }
      )
    }

    $keystone_config = [
      'env.OS_PROJECT_NAME admin',
      "env.OS_USERNAME ${keystone_username}",
      "env.OS_PASSWORD ${keystone_pass}",
      "env.OS_AUTH_URL ${keystone_url}",
      'env.OS_IDENTITY_API_VERSION 3',
    ]
  } else {
    $keystone_config = []
  }

  munin::plugin { $name:
    ensure => present,
    source => "puppet:///modules/profile/muninplugins/${plugin_file}",
    config => $generic_config + $keystone_config + $plugin_extra_config,
  }
}
