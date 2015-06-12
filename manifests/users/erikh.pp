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
  
#  ssh_authorized_key { "erikh@manager":
#    user => "erikh",
#    type => 'ssh-rsa',
#    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCeuK+xxL/Y6EQDVv7HHrrrMygk85LfzwLxZxY5LR+xzUlwYjdkpFmoN18t4k1ziDUHRjTmp9pdQTVmYaB82l8bQqzU21nuOo7UrUUnue9/hXXI+If2WgFSxhmBsajmRm+jhzWKkUo8aVddAyhBhPMl0C+3GY3g5N0Hf59meXLNVXAhSgXvbINn66/NczUsMFulPAebckhf77I2Kv0ENPZndnW97nPKN7pb5Ng48mRNTo+zKJKi0v9JPZu8CaHZcPZgk3aBEFUpbOSfYYesUtd8ynIsV2mJkhmufKBU/Q9RneEBLG6CEghq30MQxTeKrg++jLQbd5UXrBYy1kMtHr8x',
#    require => File['/home/erikh/.ssh'], 
#  }
}
