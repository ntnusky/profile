# Configures the dashboard.
class profile::services::dashboard::config::dns {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/shiftleader/settings.ini')

  $domains = hiera_hash('profile::dns::zones')
  $servers = unique(values($domains))

  ini_setting { 'Machineadmin DNS Servers':
    ensure  => present,
    path    => $configfile,
    section => 'DNS',
    setting => 'servers',
    value   => join($servers, ','),
    require => [
              File['/etc/shiftleader'],
            ],
  }

  $domains.each |String $key, String $value| {
    ini_setting { "Machineadmin DNS Domain ${key}":
      ensure  => present,
      path    => $configfile,
      section => 'Domains',
      setting => $key,
      value   => $value,
      require => [
                File['/etc/shiftleader'],
              ],
    }
  }

  ::profile::services::dashboard::config::dns::server { $servers : }
}
