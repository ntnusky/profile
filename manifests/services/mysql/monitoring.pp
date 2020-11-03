# Sets up monitoring of the mysql server
class profile::services::mysql::monitoring {
  $installmunin = hiera('profile::munin::install', true)
  if($installmunin) {
    include ::profile::monitoring::munin::plugin::mysql
  }

  $installsensu = hiera('profile::sensu::install', true)
  if ($installsensu) {
    include ::profile::sensu::plugin::mysql
    sensu::subscription { 'mysql': }
  }
}
