define setDHCP {
  $method = hiera("profile::interfaces::${name}::method")
  $address = hiera("profile::interfaces::${name}::address", false)
  $netmask = hiera("profile::interfaces::${name}::netmask", "255.255.255.0")

  network::interface{ $name:
    method  => $method,
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
  
  include ::keystone::client
  include ::cinder::client
  include ::nova::client
  include ::neutron::client
  include ::glance::client
  
  class { '::ntp':
    servers   => [ 'ntp.hig.no'],
    restrict  => [
      'default kod nomodify notrap nopeer noquery',
      '-6 default kod nomodify notrap nopeer noquery',
    ],
  }

  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main',
    key        => '1054B7A24BD6EC30',
    key_server => 'pgp.mit.edu',
  } ->
  package { 'puppet':
    ensure => '3.8.4-1puppetlabs1',
  } ->
  ini_setting { "Puppet Start":
    ensure  => present,
    path    => '/etc/default/puppet',
    section => '',
    setting => 'START',
    value   => 'yes',
  } ->
  service { 'puppet':
    ensure => 'running',
  }
  
  $interfacesToConfigure = hiera("profile::interfaces", false)
  if($interfacesToConfigure) {
    setDHCP { $interfacesToConfigure: }
  }

#  mount{'/fill':
#    ensure => absent,
#  } ->
#  logical_volume { 'fill':
#    ensure       => absent,
#    volume_group => 'hdd',
#  }
}
