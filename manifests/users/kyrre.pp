class profile::users::kyrre {
  user { 'kyrre':
    ensure      => present,
    gid         => 'users',
    require     => Group['users'],
    groups      => ['sudo'],
    uid         => 802,
    shell       => '/bin/bash',
    home        => '/home/kyrre',
    managehome  => true,
    password    => hiera("profile::user::kyrre::hash"),
  }
  
  file { "/home/kyrre/.ssh":
    owner    => "kyrre",
    group    => "users",
    mode     => 700,
    ensure   => "directory",
    require  => User['kyrre'],
  }
  
  ssh_authorized_key { "kyrre@rimtussa.local":
    user => "kyrre",
    type => 'ssh-rsa',
    key =>	'AAAAB3NzaC1yc2EAAAADAQABAAABAQCo2QITxryJgC6QoPF/0lEatYMMtRdOB6tcHbe9Z7FGrGEb23wflxKdL6A8kvc05QWQh54Hsw3ad4QyAPV5UHSqBLoXKrcAjQkeGG6DvDKiuyDaFVaqPTCs4UxxycEFRoMH3wtWLS5pGAEafxfHLTCq6ijOhIZtptZ/ukAoHQ71LqKsh0jMrcaAYtOFavxg3BcKxt6thsxDeMrZyj4oNHWOsQW1zs9hywPc9HfXPRiFhNeuiEnb2rlog8Q1Yn43TvCg+p7HVT/pCsXsnSmNdNRF1v6zFb1hEwvOsvn2fNyFpkWVCYLx10ZfPecvMVTnFVTGU77WTKIDM6LpJ+oxiTbX',
    require => File['/home/kyrre/.ssh'], 
  }
}
