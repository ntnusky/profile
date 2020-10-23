# This class installs and configures the postgresql server
class profile::services::postgresql {
  contain profile::services::postgresql::backup
  contain profile::services::postgresql::firewall
  contain profile::services::postgresql::server

  $installmunin = hiera('profile::munin::install', true)
  if($installmunin) {
    include ::profile::monitoring::munin::plugin::postgresql
  }
}
