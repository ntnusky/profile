# Creates DNS server based on data from hiera
define profile::services::dashboard::config::dns::server {
  $ipv4 = hiera("profile::dns::${name}::ipv4")
  $key = hiera("profile::dns::${name}::key", false)

  $configfile = hiera('profile::dashboard::configfile',
      '/etc/shiftleader/settings.ini')

  ini_setting { "Machineadmin DNS Server ${name} Address":
    ensure  => present,
    path    => $configfile,
    section => 'DNS',
    setting => "${name}Address",
    value   => $ipv4,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  if($key) {
    ini_setting { "Machineadmin DNS Server ${name} Key":
      ensure  => present,
      path    => $configfile,
      section => 'DNS',
      setting => "${name}Key",
      value   => $key,
      require => [
                File['/etc/shiftleader'],
              ],
    }
  }
}
