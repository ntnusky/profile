class profile::users::eigil {
  user { 'eigil':
    ensure      => present,
    gid         => 'users',
    require     => Group['users'],
    groups      => ['sudo'],
    uid         => 801,
    shell       => '/bin/bash',
    home        => '/home/eigil',
    managehome  => true,
    password    => hiera("profile::user::eigil::hash"),
  }
  
  file { "/home/eigil/.ssh":
    owner    => "eigil",
    group    => "users",
    mode     => 700,
    ensure   => "directory",
    require  => User['eigil'],
  }
  
  ssh_authorized_key { "eigil@manager":
    user => "eigil",
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDAIZCLd5pEiYCx1+WJcqPUOXOKVqgByL1Rbk0MRNqL+xJUBGQjyrS1GQryHadf++PanUxPju6NMOD+TkJU/yAf8lbGZLkZgQGKG8xKTC6o5ZWpoUoldNffPE3RdGqXM8REQG8KuUzr4U02n4ESVAr/1/vtkt/LotLf+/ej4hKopZ++LA/DIp70FUEbKINbc5bDdUKFtxC0a7hC1su/wD+bqMVotH9ErQdMY+0hlUXEvxohrnxNdMViGQpvyTYV6rET1UVFLJ8iedFj4cFaI8rvV681UtHGPPNM7o5+dH/eJjwwJav4aRLTBhYMJMJbbdxT/fC6hQVCFJ8Ovna4Ans5',
    require => File['/home/eigil/.ssh'], 
  }
}
