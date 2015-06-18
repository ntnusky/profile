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
  
  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main',
    release    => 'trusty',
#    key        => '1054B7A24BD6EC30', # old key which works but complains its short
    key        => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
    key_server => 'pgp.mit.edu',
  } ->
  package { 'puppet':
    ensure => '3.8.1-1puppetlabs1',
  } ->
  ini_setting { 'enablepuppet': 
    ensure  => present, 
    path    => '/etc/default/puppet', 
    section => '', 
    setting => 'START', 
    value   => 'yes' 
  } ~>
  service { 'puppet':
    ensure => 'running',
  }

  $interfacesToConfigure = hiera("profile::interfaces", false)
  if($interfacesToConfigure) {
	setDHCP { $interfacesToConfigure: }
  }
}
