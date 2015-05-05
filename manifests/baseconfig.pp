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
	
	class { '::ntp':
		servers => [ '0.no.pool.ntp.org', 
			'1.no.pool.ntp.org',  
			'2.no.pool.ntp.org',  
			'3.no.pool.ntp.org' 
		],
	}
}
