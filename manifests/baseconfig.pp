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
  
  exec { "wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && dpkg -i puppetlabs-release-trusty.deb":
    unless => "dpkg -l | grep puppetlabs",
    path   => "/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin",
  } ->
  package { 'puppet':
    ensure => '3.8.1-1puppetlabs1',
  } ->
  ini_setting { 'enablepuppet': 
    ensure => present, 
    path => '/etc/default/puppet', 
    section => '', 
    setting => 'START', 
    value => 'yes' 
  } ~>
  service { 'puppet':
    ensure => 'running',
  }

  $interfacesToConfigure = hiera("profile::interfaces", false)
  if($interfacesToConfigure) {
	setDHCP { $interfacesToConfigure: }
  }
}
