# Configures the dashboard.
class profile::services::dashboard::config::puppet {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')

  $puppetserver = hiera('profile::puppet::hostname')
  $puppetca = hiera('profile::puppet::caserver')

  ini_setting { 'Machineadmin puppet server':
    ensure  => present,
    path    => $configfile,
    section => 'puppet',
    setting => 'server',
    value   => $puppetserver,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { 'Machineadmin puppet caserver':
    ensure  => present,
    path    => $configfile,
    section => 'puppet',
    setting => 'caserver',
    value   => $puppetca,
    require => [
              File['/etc/machineadmin'],
            ],
  }

}
