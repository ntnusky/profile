# This define sets up a generic plugin for munin.
define profile::monitoring::munin::plugin::generic (
  $plugin_extra_config = [],
  $plugin_user = 'root',
  $plugin_file = $name,
) {
  include ::ntnuopenstack::clients

  $generic_config = [
    "user ${plugin_user}",
  ]

  munin::plugin { $name:
    ensure => present,
    source => "puppet:///modules/profile/muninplugins/${plugin_file}",
    config => $generic_config + $plugin_extra_config,
  }
}
