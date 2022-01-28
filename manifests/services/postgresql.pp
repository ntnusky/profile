# This class installs and configures the postgresql server
class profile::services::postgresql {
  contain profile::services::postgresql::backup
  contain profile::services::postgresql::firewall
  contain profile::services::postgresql::server

  $install_munin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })
  if($install_munin) {
    include ::profile::monitoring::munin::plugin::postgresql
  }
}
