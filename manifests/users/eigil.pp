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
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCu6593qsTa1Z+dLR0VUjjh4rVEhTMBe8jz99ioc216GWet/7zwMvwoyrjxdyGWdq6F3tGFWuk9xzVkmSs8a+rg/FRCwZFbSC16xGOALqFtkygBCNORgPjeRch+ID5D64z7Yk6mBZHs4itABk29KTEcKuvFtWbEGdvUjbL01/GjgQiyhFg3F3SXeflnCmXOS05AtQ85c4/tUYJN59IX1VTEg6ZUKDGJrJRpJJiAg59TCrLAMGLQfm7lvRYpki2+AgiQn5ntJEiA5+A/XRKI8GqbKVZ6A3UVe55MqJqoXJUW7yNgPBE6Iwri4CbwJUN2My8H7v6N1733nD/W+7EG/PrN',
    require => File['/home/eigil/.ssh'], 
  }
}
