class profile::baseconfig {
  if($::bios_vendor == "HP") {
    include ::hpacucli
  }

  anchor { "profile::baseconfig::start" : }->
  package { [
    'fio',
    'git',
    'htop',
    'nmap',
    'pwgen',
    'sysstat',
    'vim'
  ] :
    ensure => 'latest',
  } ->
  
  class { '::ntp':
    servers => [ 'ntp.hig.no'],
  }->
  anchor { "profile::baseconfig::end" : }
}
