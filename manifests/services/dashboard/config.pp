# Configures the dashboard.
class profile::services::dashboard::config {
  $databasetype = hiera('profile::dashboard::database::type')

  if($databasetype == 'mysql') {
    contain ::profile::services::dashboard::config::mysql
  }
  if($databasetype == 'sqlite') {
    contain ::profile::services::dashboard::config::sqlite
  }

  contain ::profile::services::dashboard::config::dhcp
  contain ::profile::services::dashboard::config::ldap
  contain ::profile::services::dashboard::config::general
}
