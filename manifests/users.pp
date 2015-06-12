class profile::users {
  group { 'users':
    ensure => present,
    gid => 700,
  }

  file { "/root/.ssh":
    owner    => "root",
    group    => "root",
    mode     => 700,
    ensure   => "directory",
  }
  ssh_authorized_key { "root@manager":
    user => "root",
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC2dg0IiMelKaB4UTF1r6O7lPC2YCWLhQmDYAY4zdpZ/phdodWcSARpMkCncMNCPw6GxGdMi74U2QgFjUSRRAnO+Cw56HoqNWTq2MshiFU/ay3gJqr+pleELU00PnHfu6uL2Tiarh3f3eJYCQXysniLwWbsf929mgeDXv/NEJFyX9A+YGok2H0AHs5bPl1JqFRzZx8zYPPK04P7g2bXyFGRWFL0tlczqgavmP+ews/vqD6wItI0tLPToqIpL1tgEH77LpV9/ZXTz9PyvOLanEuB3INqjM9hqlaWN03361yKKOtwH46/AMJdafFUFZIhomJd9MkCCGQNtCg4EYiiJs+f',
    require => File['/root/.ssh'], 
  }
  
  include ::profile::users::eigil
  include ::profile::users::erikh
}
