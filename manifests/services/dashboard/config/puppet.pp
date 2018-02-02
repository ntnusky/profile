# Configures the dashboard.
class profile::services::dashboard::config::puppet {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/shiftleader/settings.ini')

  $puppetserver = hiera('profile::puppet::hostname')
  $puppetca = hiera('profile::puppet::caserver')
  $runinterval = hiera('profile::puppet::runinterval')

  ini_setting { 'Machineadmin puppet server':
    ensure  => present,
    path    => $configfile,
    section => 'puppet',
    setting => 'server',
    value   => $puppetserver,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { 'Machineadmin puppet caserver':
    ensure  => present,
    path    => $configfile,
    section => 'puppet',
    setting => 'caserver',
    value   => $puppetca,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { 'Machineadmin puppet runinterval':
    ensure  => present,
    path    => $configfile,
    section => 'puppet',
    setting => 'runinterval',
    value   => $runinterval,
    require => [
              File['/etc/shiftleader'],
            ],
  }
}
