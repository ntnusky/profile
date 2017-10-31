# Configures the dashboard.
class profile::services::dashboard::config::dhcp {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/shiftleader/settings.ini')

  $pools = hiera_array('profile::networks')
  $servers = keys(hiera_hash('profile::dhcp::servers'))

  ini_setting { 'Machineadmin DHCP Pools':
    ensure  => present,
    path    => $configfile,
    section => 'DHCP',
    setting => 'pools',
    value   => join($pools, ','),
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { 'Machineadmin DHCP Servers':
    ensure  => present,
    path    => $configfile,
    section => 'DHCP-SERVERS',
    setting => 'servers',
    value   => join($servers, ','),
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ::profile::services::dashboard::config::dhcp::pool { $pools : }
  ::profile::services::dashboard::config::dhcp::server { $servers : }
}
