# Creates DHCP pool based on data from hiera
define profile::services::dashboard::config::dhcp::server {
  $servers = hiera_hash('profile::dhcp::servers')
  $host = $servers[$name]
  $keyname = hiera('profile::dhcp::omapi::name')
  $key = hiera('profile::dhcp::omapi::key')
  $port = 7911

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
