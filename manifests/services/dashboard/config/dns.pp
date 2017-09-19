# Configures the dashboard.
class profile::services::dashboard::config::dns {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')

  $servers = hiera_array('profile::dns::servers::names')
  $domains = hiera_hash('profile::dns::domains')

  ini_setting { 'Machineadmin DNS Servers':
    ensure  => present,
    path    => $configfile,
    section => 'DNS',
    setting => 'servers',
    value   => join($servers, ','),
    require => [
              File['/etc/machineadmin'],
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
                File['/etc/machineadmin'],
              ],
    }
  }

  ::profile::services::dashboard::config::dns::server { $servers : }
}
