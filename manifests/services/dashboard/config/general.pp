# Configures the dashboard.
class profile::services::dashboard::config::general {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')
  $django_secret = hiera('profile::dashboard::django::secret')
  $dashboardname = hiera('profile::dashboard::name')
  $apiurl = hiera('profile::dashboard::api')

  file { '/etc/machineadmin':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  ini_setting { 'Machineadmin debug':
    ensure  => present,
    path    => $configfile,
    section => 'general',
    setting => 'debug',
    value   => false,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { 'Machineadmin API':
    ensure  => present,
    path    => $configfile,
    section => 'general',
    setting => 'api',
    value   => $apiurl,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { 'Machineadmin django secret':
    ensure  => present,
    path    => $configfile,
    section => 'general',
    setting => 'secret',
    value   => $django_secret,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { 'Machineadmin main host':
    ensure  => present,
    path    => $configfile,
    section => 'hosts',
    setting => 'main',
    value   => $dashboardname,
    require => [
              File['/etc/machineadmin'],
            ],
  }

}
