# Configures the dashboard.
class profile::services::dashboard::config::mysql {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/shiftleader/settings.ini')
  $database_name = hiera('profile::dashboard::database::name')
  $database_host = hiera('profile::dashboard::database::host')
  $database_user = hiera('profile::dashboard::database::user')
  $database_pass = hiera('profile::dashboard::database::pass')

  ini_setting { 'Machineadmin db type':
    ensure  => present,
    path    => $configfile,
    section => 'database',
    setting => 'type',
    value   => 'mysql',
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { 'Machineadmin db host':
    ensure  => present,
    path    => $configfile,
    section => 'database',
    setting => 'host',
    value   => $database_host,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { 'Machineadmin db name':
    ensure  => present,
    path    => $configfile,
    section => 'database',
    setting => 'name',
    value   => $database_name,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { 'Machineadmin db user':
    ensure  => present,
    path    => $configfile,
    section => 'database',
    setting => 'user',
    value   => $database_user,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { 'Machineadmin db password':
    ensure  => present,
    path    => $configfile,
    section => 'database',
    setting => 'password',
    value   => $database_pass,
    require => [
              File['/etc/shiftleader'],
            ],
  }
}
