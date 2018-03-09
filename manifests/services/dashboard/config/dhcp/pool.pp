# Creates DHCP pool based on data from hiera
define profile::services::dashboard::config::dhcp::pool {
  $network = hiera("profile::networks::${name}::ipv4::id")
  $mask = hiera("profile::networks::${name}::ipv4::mask")
  $gateway = hiera("profile::networks::${name}::ipv4::gateway", false)
  $domain = hiera("profile::networks::${name}::domain")
  $range = hiera("profile::networks::${name}::ipv4::dynamicrange", '')
  $reserved = hiera_array("profile::networks::${name}::ipv4::reserved", [])
  $v6prefix = hiera("profile::networks::${name}::ipv6::prefix", false)

  $configfile = hiera('profile::dashboard::configfile',
      '/etc/shiftleader/settings.ini')

  ini_setting { "Machineadmin DHCP Pool ${name} id":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP',
    setting => "${name}Network",
    value   => $network,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { "Machineadmin DHCP Pool ${name} domain":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP',
    setting => "${name}Domain",
    value   => $domain,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  ini_setting { "Machineadmin DHCP Pool ${name} mask":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP',
    setting => "${name}Netmask",
    value   => $mask,
    require => [
              File['/etc/shiftleader'],
            ],
  }
  
  if($gateway) {
    ini_setting { "Machineadmin DHCP Pool ${name} gateway":
      ensure  => present,
      path    => $configfile,
      section => 'DHCP',
      setting => "${name}Gateway",
      value   => $gateway,
      require => [
                File['/etc/shiftleader'],
              ],
    }
  } else {
    ini_setting { "Machineadmin DHCP Pool ${name} gateway":
      ensure  => absent,
      path    => $configfile,
      section => 'DHCP',
      setting => "${name}Gateway",
      require => [
                File['/etc/shiftleader'],
              ],
    }
  }

  $range2 = regsubst($range, ' ', '-', 'G')
  ini_setting { "Machineadmin DHCP Pool ${name} range":
    ensure  => present,
    path    => $configfile,
    section => 'DHCP',
    setting => "${name}Reserved",
    value   => join(concat($reserved, $range2), ','),
    require => [
              File['/etc/shiftleader'],
            ],
  }

  if($v6prefix) {
    ini_setting { "Machineadmin DHCP Pool ${name} v6prefix":
      ensure  => present,
      path    => $configfile,
      section => 'DHCP',
      setting => "${name}v6prefix",
      value   => $v6prefix,
      require => [
                File['/etc/shiftleader'],
              ],
    }
  } else {
    ini_setting { "Machineadmin DHCP Pool ${name} v6prefix":
      ensure  => absent,
      path    => $configfile,
      section => 'DHCP',
      setting => "${name}v6prefix",
      require => [
                File['/etc/shiftleader'],
              ],
    }

  }
}
