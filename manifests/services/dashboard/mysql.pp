# Configures the dashboard.
class profile::services::dashboard::mysql {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')
  $database_name = hiera('profile::dashboard::database::name')
  $database_host = hiera('profile::dashboard::database::host')
  $database_user = hiera('profile::dashboard::database::user')
  $database_pass = hiera('profile::dashboard::database::pass')

  mysql::db { $database_name:
    user     => $databse_user,
    password => $databse_pass,
    host     => $databse_host,
    grant    => ['CREATE', 'ALTER', 'DELETE', 'INSERT', 'SELECT', 'UPDATE',
                  'INDEX', 'DROP',
                ],
    require  => Class['::profile::mysql::cluster'],
  }
}
