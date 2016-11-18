# Creates user 'larserik'
class profile::users::larserik {
  user { 'larserik':
    ensure     => present,
    gid        => 'users',
    require    => Group['users'],
    groups     => ['sudo'],
    uid        => 803,
    shell      => '/bin/bash',
    home       => '/home/larserik',
    managehome => true,
    password   => hiera('profile::user::larserik::hash'),
  }
  
  file { '/home/larserik/.ssh':
    ensure  => 'directory',
    owner   => 'larserik',
    group   => 'users',
    mode    => '0700',
    require => User['larserik'],
  }

  ssh_authorized_key { 'larserik@sarah':
    user    => 'larserik',
    type    => 'ssh-rsa',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQCwFrm/iRtOpOrRzd/Sxe8zFOKnScuTqAAONj4IxX+D59fg+53kOTYI8Gn6Q54dUb8aurS8as92LH2Y8quzrGSt8ZP8pT8JxuDyhWlPcFGo82krdCkZPLK5wRhwYAsNSUVrQJcb2e0kNAR0/wBkQxd70WbW4uCJlzQr9v/9SJEnUr+Gv9ImBbcOF2zpo1+b2Sy3syOMOnnPdNi9HZy0OktyMl2vo2+tjavUSqv7khI3RktYdWbV/TZ/sCuRh26KPtMzIL3sjCEOIm9i3UY5KBBLZpOMZEE5Tq6BVVrE1I8lZKoLBm4s9OI8kEGYDP+7FREigqozr8yUWy+dZisH6YhG4Uk6KKhhoyuii/MC6o0BpaW++0JkUeUvadpzNie4DlLIduJSNWJMiuHvvkmO8HUWZs/KDUUzmDzPBbjQStiT8AAXdrluRR80yI1U9qSAdbhu5I36t+z+5F2F9OBArpbIAoogRQDah9VMCVdCQLkw0G07wzgLbUWEYiKKSLyDkyeZArXRXAqxbi8BOX3lqPhtqcAGroSPJlN74lR5TFTz3RDZWWaYzYeWWeg8jgAHNQYuAx0EtFdLnPHe2p6eLQXWEcZPpTPQD7VepS6IssigEpZ8pqlq2Eax2lvuOYdqigSXC6YxF+dhLZ8BhhwUUkGtW00D6ubaFWxgvr/N3A9nCQ',
    require => File['/home/larserik.ssh'],
  }
}
