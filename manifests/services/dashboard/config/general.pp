# Configures the dashboard.
class profile::services::dashboard::config::general {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/shiftleader/settings.ini')
  $django_secret = hiera('profile::dashboard::django::secret')
  $dashboardname = hiera('profile::dashboard::name')
  $dashboardv4name = hiera('profile::dashboard::name::v4only', false)
  $apiurl = hiera('profile::dashboard::api')
  $installEnvironment = hiera('profile::productionlevel', false)

  file { '/etc/shiftleader':
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
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { 'Machineadmin API':
    ensure  => present,
    path    => $configfile,
    section => 'general',
    setting => 'api',
    value   => $apiurl,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { 'Machineadmin django secret':
    ensure  => present,
    path    => $configfile,
    section => 'general',
    setting => 'secret',
    value   => $django_secret,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { 'Machineadmin main host':
    ensure  => present,
    path    => $configfile,
    section => 'hosts',
    setting => 'main',
    value   => $dashboardname,
    require => [
              File['/etc/shiftleader'],
            ],
  }
  
  if($dashboardv4name) {
    ini_setting { 'Machineadmin ipv4 host':
      ensure  => present,
      path    => $configfile,
      section => 'hosts',
      setting => 'ipv4',
      value   => $dashboardv4name,
      require => [
                File['/etc/shiftleader'],
              ],
    }
  }

  if($installEnvironment) {
    ini_setting { 'Machineadmin ipv4 host':
      ensure  => present,
      path    => $configfile,
      section => 'general',
      setting => 'env',
      value   => $installEnvironment,
      require => [
                File['/etc/shiftleader'],
              ],
    }
  }
}
