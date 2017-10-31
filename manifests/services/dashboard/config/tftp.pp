# Configures the dashboard.
class profile::services::dashboard::config::tftp {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/shiftleader/settings.ini')

  $rootdir = hiera('profile::tftp::root', '/var/lib/tftpboot/')
  ini_setting { 'Machineadmin TFTP location':
    ensure  => present,
    path    => $configfile,
    section => 'TFTP',
    setting => 'rootdir',
    value   => $rootdir,
    require => [
              File['/etc/shiftleader'],
            ],
  }
}
