# Configures the dashboard.
class profile::services::dashboard::config::sqlite {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/shiftleader/settings.ini')
  $database_location = hiera('profile::dashboard::datadir')

  file { $database_location :
    ensure => 'directory',
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0770',
  }

  file { "${database_location}/db.sqlite":
    ensure => 'file',
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0660',
  }

  ini_setting { 'Machineadmin db type':
    ensure  => present,
    path    => $configfile,
    section => 'database',
    setting => 'type',
    value   => 'sqlite',
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { 'Machineadmin db name':
    ensure  => present,
    path    => $configfile,
    section => 'database',
    setting => 'name',
    value   => "${database_location}/db.sqlite",
    require => [
              File['/etc/shiftleader'],
            ],
  }
}
