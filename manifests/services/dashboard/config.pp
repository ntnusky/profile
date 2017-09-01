# Configures the dashboard.
class profile::services::dashboard::config {
  $databasetype = hiera('profile::dashboard::database::type')

  if($databasetype == 'mysql') {
    contain ::profile::services::config::mysql
  }
  if($databasetype == 'sqlite') {
    contain ::profile::services::config::sqlite
  }

  contain ::profile::services::config::ldap
  contain ::profile::services::config::general
}
