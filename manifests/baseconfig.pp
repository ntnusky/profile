define setDHCP {
  $method = hiera("profile::interfaces::${name}::method")
  $address = hiera("profile::interfaces::${name}::address", false)
  $netmask = hiera("profile::interfaces::${name}::netmask", "255.255.255.0")

  network::interface{ $name:
    method => $method,
    address => $address,
    netmask => $netmask,
  }
}

class profile::baseconfig {
  if($::bios_vendor == "HP") {
    include ::hpacucli
  }

  package { [
    'fio',
    'git',
	'gdisk',
    'htop',
	'iperf3',
    'nmap',
    'pwgen',
    'sysstat',
    'vim'
  ] :
    ensure => 'latest',
  }
  
  class { '::ntp':
    servers => [ 'ntp.hig.no'],
  }
  
  $interfacesToConfigure = hiera("profile::interfaces", false)
  if($interfacesToConfigure) {
	setDHCP { $interfacesToConfigure: }
  }

  mount{'/fill':
    ensure => absent,
  } ->
  logical_volume { 'fill':
    ensure       => absent,
    volume_group => 'hdd',
  }
}
