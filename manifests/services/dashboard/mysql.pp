# Configures the dashboard.
class profile::services::dashboard::mysql {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')
  $database_name = hiera('profile::dashboard::database::name')
  $database_grant = hiera('profile::dashboard::database::grant')
  $database_user = hiera('profile::dashboard::database::user')
  $database_pass = hiera('profile::dashboard::database::pass')

  ::openstacklib::db::mysql { $database_name:
    password      = mysql_password($database_pass),
    user          = $database_user,
    host          = $database_grant,
    allowed_hosts = [$database_grant],
  }
}
