class profile::users::larserik {
  user { 'larserik':
    ensure      => present,
    gid         => 'users',
    require     => Group['users'],
    groups      => ['sudo'],
    uid         => 803,
    shell       => '/bin/bash',
    home        => '/home/larserik',
    managehome  => true,
    password    => hiera("profile::user::larserik::hash"),
  }
  
  file { "/home/larserik/.ssh":
    owner    => "larserik",
    group    => "users",
    mode     => 700,
    ensure   => "directory",
    require  => User['larserik'],
  }
}
