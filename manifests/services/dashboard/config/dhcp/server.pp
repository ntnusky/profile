# Creates DHCP pool based on data from hiera
define profile::services::dashboard::config::dhcp::server {
  $host = hiera("profile::dhcp::${name}::address")
  $port = hiera("profile::dhcp::${name}::omapiport", 7911)
  $keyname = hiera("profile::dhcp::${name}::keyname")
  $key = hiera("profile::dhcp::${name}::key")

  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')

  ini_setting { "Machineadmin DHCP Server ${name} Address":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP-SERVERS',
    setting => "${name}Host",
    value   => $host,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { "Machineadmin DHCP Server ${name} Port":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP-SERVERS',
    setting => "${name}Port",
    value   => $port,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { "Machineadmin DHCP Server ${name} Keyname":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP-SERVERS',
    setting => "${name}Keyname",
    value   => $keyname,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { "Machineadmin DHCP Server ${name} Key":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP-SERVERS',
    setting => "${name}Key",
    value   => $key,
    require => [
              File['/etc/machineadmin'],
            ],
  }
}
