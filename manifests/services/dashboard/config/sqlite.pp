# Configures the dashboard.
class profile::services::dashboard::config::sqlite {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')
  $database_location = hiera('profile::dashboard::database::name')

  ini_setting { 'Machineadmin db type':
    ensure  => present,
    path    => $configfile,
    section => 'database',
    setting => 'type',
    value   => 'sqlite',
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { 'Machineadmin db name':
    ensure  => present,
    path    => $configfile,
    section => 'database',
    setting => 'name',
    value   => $database_location,
    require => [
              File['/etc/machineadmin'],
            ],
  }
}
