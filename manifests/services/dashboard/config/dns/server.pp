# Creates DNS server based on data from hiera
define profile::services::dashboard::config::dns::server {
  $host = hiera("profile::dns::${name}::address")
  $key = hiera("profile::dns::${name}::key", false)

  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')

  ini_setting { "Machineadmin DNS Server ${name} Address":
    ensure  => present,
    path    => $configfile,
    section => 'DNS',
    setting => "${name}Address",
    value   => $host,
    require => [
              File['/etc/machineadmin'],
            ],
  }
  
  if($key) {
    ini_setting { "Machineadmin DNS Server ${name} Key":
      ensure  => present,
      path    => $configfile,
      section => 'DNS',
      setting => "${name}Key",
      value   => $port,
      require => [
                File['/etc/machineadmin'],
              ],
    }
  }
}
