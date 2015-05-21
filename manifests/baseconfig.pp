class profile::baseconfig {
  include ::hpacucli

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
  
  file { "/etc/hosts":
    owner => "root",
    group => "root",
    mode  => 444,
    source => "puppet:///modules/profile/hosts",
  } ->  
  
  file { "/etc/resolvconf/resolv.conf.d/tail" :
    ensure => file,
    content => "nameserver 128.39.243.10",
    mode => 644,
    owner => "root",
    group => "root",
  } ->

  ssh_authorized_key { "eigil@carajillo":
    user => "eigil",
    type => 'ssh-rsa',
    key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDwe4N6Op3OEDYxe/SeHr58jgq7/Ip7uSDLYuOtJl40/IHVWyCwMfQwFWgIzNM+8Obpu9uRvwp85hF7PHoM5MTNgcPGhlJeFUkHbiUu3fhlj4k+YmiW9NpotNbVbTw0s3m2PLVruEvVm8fQ376XTJO2jTOfx7DC25dV+UqAe7XtmZra6l2wEZPr2UN5W7TGr3Th19dkBiQBQMxIGFd/toKOniFdq/+JBp6OH+ZMQ8QIgKkAQ/AKCxYROkxYvWblvOtjk0kehaJkn3b6wjgyMf80yxLvOd4jaX7LO/G8kXjXQ+1gwVImvG0Cw4yG5D20Y+UspwahXeRV5Ik72qsF3ezX",
  } ->
  
  ssh_authorized_key { "root@manager":
    user => "root",
    type => 'ssh-rsa',
    key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDkc0epI9xYbQgxheiv2w6es/pRnyA0BvUSA/dUvnxjt/CRdWT+z57xaUYVmlwdLTzmisPSxvUov24URpRZhkwLpSKICpsY/hbHii0OE01fWTJrAThAD9SDzyhj6BnB8cLsA8M+tcvqdB9aqOfUfqr7aUwvjDDFzD57Wj7p9TWXl7U0pMHKa5tshNhZNdEVlUwLCU3PM7ucQxvRkNeKiKkul9nMEkw659JGlFQWbeD9mhPGjM8tNLuyBGb3K+RrtBRf5XZfuW8Xu05dB9hqmSjxGLrQuu50SRQdde1n6yh0B9+XvP7QQOXkmVTWspMbnJDnMwbycp9NLS4WCV5Rl3rN",
  } ->
  
  class { '::ntp':
    servers => [ 'ntp.hig.no'],
  }->
  anchor { "profile::baseconfig::end" : }
}
