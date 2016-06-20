define setDHCP {
  $method = hiera("profile::interfaces::${name}::method")
  $address = hiera("profile::interfaces::${name}::address", false)
  $netmask = hiera("profile::interfaces::${name}::netmask", "255.255.255.0")

  $mysql_master = hiera("profile::mysqlcluster::master")

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
    'bc',
    'fio',
    'git',
    'gdisk',
    'htop',
    'iperf3',
    'pwgen',
    'sysstat',
    'vim'
  ] :
    ensure => 'latest',
  }

  # This check were supposed to not install nmap on the galera master, as the
  # galera module ensures namp is installed on this node. It did not work as
  # intended, and should be fixed at some point if one want nmap on all nodes.
  #
  #if($::fqdn != $mysql_master) {
  #  package { 'nmap':
  #    ensure => 'latest',
  #    }
  #}
  
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
    ensure => '3.8.7-1puppetlabs1',
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
