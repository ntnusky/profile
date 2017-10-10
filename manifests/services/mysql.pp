# Configuring galera and maraidb cluster
class profile::services::mysql {
  include ::profile::services::mysql::cluster
  include ::profile::services::mysql::haproxy::backend
  include ::profile::services::mysql::users

  $installsensu = hiera('profile::sensu::install', true)
  if ($installsensu) {
    include ::profile::sensu::plugin::mysql
  }
}
