# Configuring galera and maraidb cluster
class profile::services::mysql {
  include ::profile::services::mysql::backup
  include ::profile::services::mysql::cluster
  include ::profile::services::mysql::firewall::server
  include ::profile::services::mysql::haproxy::backend
  include ::profile::services::mysql::users

  $installMunin = hiera('profile::munin::install', true)
  if($installMunin) {
    include ::profile::monitoring::munin::plugin::mysql
  }
  $installsensu = hiera('profile::sensu::install', true)
  if ($installsensu) {
    include ::profile::sensu::plugin::mysql
  }
}
