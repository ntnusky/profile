# Creates DNS server based on data from hiera
define profile::services::dashboard::config::dns::server {
  $ipv4 = hiera("profile::dns::${name}::ipv4")
  $key = hiera("profile::dns::${name}::key", false)
  $keyname = hiera("profile::dns::${name}::keyname", false)
  $algorithm = hiera("profile::dns::${name}::algorithm", false)

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
    $keyensure = 'present'
  } else {
    $keyensure = 'absent'
  }

  ini_setting { "Machineadmin DNS Server ${name} Key":
    ensure  => $keyensure,
    path    => $configfile,
    section => 'DNS',
    setting => "${name}Key",
    value   => $key,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  if($keyname) {
    $nameensure = 'present'
  } else {
    $nameensure = 'absent'
  }

  ini_setting { "Machineadmin DNS Server ${name} Name":
    ensure  => $nameensure,
    path    => $configfile,
    section => 'DNS',
    setting => "${name}Keyname",
    value   => $keyname,
    require => [
              File['/etc/shiftleader'],
            ],
  }

  if($algorithm) {
    $algorithmensure = 'present'
  } else {
    $algorithmensure = 'absent'
  }

  ini_setting { "Machineadmin DNS Server ${name} Algorithm":
    ensure  => $algorithmensure,
    path    => $configfile,
    section => 'DNS',
    setting => "${name}Algorithm",
    value   => $algorithm,
    require => [
              File['/etc/shiftleader'],
            ],
  }
}
