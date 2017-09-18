# Creates DHCP pool based on data from hiera
define profile::services::dashboard::config::dhcp::pool {
  $network = hiera("profile::networks::${name}::id")
  $mask = hiera("profile::networks::${name}::mask")
  $gateway = hiera("profile::networks::${name}::gateway")
  $range = hiera("profile::networks::${name}::range")
  $reserved = hiera_array("profile::networks::${name}::reserved", [])

  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')

  ini_setting { "Machineadmin DHCP Pool ${name} id":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP',
    setting => "${name}Network",
    value   => $network,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { "Machineadmin DHCP Pool ${name} mask":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP',
    setting => "${name}Netmask",
    value   => $mask,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { "Machineadmin DHCP Pool ${name} gateway":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP',
    setting => "${name}Gateway",
    value   => $gateway,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  $range2 = regsubst($range, ' ', '-', 'G')
  ini_setting { "Machineadmin DHCP Pool ${name} range":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP',
    setting => "${name}Reserved",
    value   => join(concat([$range2], $reserved), ','),
    require => [
              File['/etc/machineadmin'],
            ],
  }
}
