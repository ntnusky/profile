class profile::baseconfig {
	anchor { "profile::baseconfig::start" : }->
	package { [
		'git',
		'htop',
		'nmap',
		'pwgen',
		'sysstat',
		'vim'
	] :
		ensure => 'latest',
	} ->

	file { "/etc/hosts":
		owner => "root",
		group => "root",
		mode  => 444,
		source => "puppet:///modules/profile/hosts",
	} ->  

	ssh_authorized_key { "eigil@carajillo":
		user => "eigil",
		type => 'ssh-rsa',
		key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDwe4N6Op3OEDYxe/SeHr58jgq7/Ip7uSDLYuOtJl40/IHVWyCwMfQwFWgIzNM+8Obpu9uRvwp85hF7PHoM5MTNgcPGhlJeFUkHbiUu3fhlj4k+YmiW9NpotNbVbTw0s3m2PLVruEvVm8fQ376XTJO2jTOfx7DC25dV+UqAe7XtmZra6l2wEZPr2UN5W7TGr3Th19dkBiQBQMxIGFd/toKOniFdq/+JBp6OH+ZMQ8QIgKkAQ/AKCxYROkxYvWblvOtjk0kehaJkn3b6wjgyMf80yxLvOd4jaX7LO/G8kXjXQ+1gwVImvG0Cw4yG5D20Y+UspwahXeRV5Ik72qsF3ezX",
	} ->
	
	class { '::ntp':
		servers => [ '0.no.pool.ntp.org', 
			'1.no.pool.ntp.org',  
			'2.no.pool.ntp.org',  
			'3.no.pool.ntp.org' 
		],
	}->
	anchor { "profile::baseconfig::end" : }
}
