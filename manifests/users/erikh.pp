class profile::users::erikh {
  user { 'erikh':
    ensure      => present,
    gid         => 'users',
    require     => Group['users'],
    groups      => ['sudo'],
    uid         => 800,
    shell       => '/bin/bash',
    home        => '/home/erikh',
    managehome  => true,
    password    => hiera("profile::user::erikh::hash"),
  }
  
  file { "/home/erikh/.ssh":
    owner    => "erikh",
    group    => "users",
    mode     => 700,
    ensure   => "directory",
    require  => User['erikh'],
  }
  
  ssh_authorized_key { "erikh@manager":
    user => "erikh",
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCtvS04s/ccez7TF35LfTCnXW7H2Pn/qGrz7QJvxi1Ve1H+IRVBkuf5CChFXdfC2nTsPXyozDxgaXxc5s8V6OEEKNhE5eHr30hKzuhatgh7Lz/7r7K5IrjTbABntC2yE2NgAxb/irnqhlDt4SG6rGFeK/MJsvUYYK6ri39VH058kVVbVOUF9BWMLEsYpLCcQ5IaQ7FvL/dErHYCD28Lmjkrumm8DYH3ClGoKOA5kymT+ETclppnz37TKHxOW+qam33RJa1lO6EOu/8d1X1wLO44/4Q3TVN+sLpP/Ejdhd1tPPeGeFf7sNn7MWHEG97+8vtjCwtYo7BZ0AJOzUDmgEcJ',
    require => File['/home/erikh/.ssh'], 
  }
}
