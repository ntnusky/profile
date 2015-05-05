class profile::baseconfig {
	package { [
		'git',
		'htop',
		'nmap',
		'pwgen',
		'sysstat',
		'vim'
	] :
		ensure => 'latest',
	}

	file { "/etc/hosts":
		owner => "root",
		group => "root",
		mode  => 444,
		source => "puppet:///modules/profile/hosts",
	}  
}
