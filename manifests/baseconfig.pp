class profile::baseconfig {
  if($::bios_vendor == "HP") {
    include ::hpacucli
  }

  package { [
    'fio',
    'git',
	'gdisk',
    'htop',
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
    path => "/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin",
  }

  $interfacesToConfigure = hiera("profile::interfaces", false)
  if($interfacesToConfigure) {
    define setDHCP {
      notify{ "Configure IF $name" : }
    }
	setDHCP { $interfacesToConfigure: }
  }
}
