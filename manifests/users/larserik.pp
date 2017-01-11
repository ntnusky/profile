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
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQCwFrm/iRtOpOrRzd/Sxe8zFOKnScuTqAAONj4IxX+D59fg+53kOTYI8Gn6Q54dUb8aurS8as92LH2Y8quzrGSt8ZP8pT8JxuDyhWlPcFGo82krdCkZPLK5wRhwYAsNSUVrQJcb2e0kNAR0/wBkQxd70WbW4uCJlzQr9v/9SJEnUr+Gv9ImBbcOF2zpo1+b2Sy3syOMOnnPdNi9HZy0OktyMl2vo2+tjavUSqv7khI3RktYdWbV/TZ/sCuRh26KPtMzIL3sjCEOIm9i3UY5KBBLZpOMZEE5Tq6BVVrE1I8lZKoLBm4s9OI8kEGYDP+7FREigqozr8yUWy+dZisH6YhG4Uk6KKhhoyuii/MC6o0BpaW++0JkUeUvadpzNie4DlLIduJSNWJMiuHvvkmO8HUWZs/KDUUzmDzPBbjQStiT8AAXdrluRR80yI1U9qSAdbhu5I36t+z+5F2F9OBArpbIAoogRQDah9VMCVdCQLkw0G07wzgLbUWEYiKKSLyDkyeZArXRXAqxbi8BOX3lqPhtqcAGroSPJlN74lR5TFTz3RDZWWaYzYeWWeg8jgAHNQYuAx0EtFdLnPHe2p6eLQXWEcZPpTPQD7VepS6IssigEpZ8pqlq2Eax2lvuOYdqigSXC6YxF+dhLZ8BhhwUUkGtW00D6ubaFWxgvr/N3A9nCQ==',
    require => File['/home/larserik/.ssh'],
  }

  ssh_authorized_key { 'larserik@manager':
    user    => 'larserik',
    type    => 'ssh-rsa',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDTy2a7heSEkJBJytlwEVq9wcwYdCmfQJFZT+VLS03g/4sfomc3cFvR8SREhtnP3dMWTqvcACb4upuUEMo+ym1gzWU66gr3xvnvpUmK0gqWLPvx4zOijV3x1cY9pgmV/uRXfnUhkUeD41VE+c7r+sS/uZk81IBi1UmWN34gY8PjZUFKTkHhH5UaXWvkuF8d3jz70EBhEPOLHldmbxsx++EuYoletsbRJ1AGFkJcG+TFL0SvXHP1JEZVtd6vR0zJEE/hzNIUCGnpHoEeIiR4XTLv/WlNN5KxSguOF6T8HKVWWrccQAweQZ29xTYkpo+3wu/Ffaetv1/paCS+8ncYU0cE4oIxjMT+WgpiOSV60btpNOolPmUUeSDNDpCWyk8awVCHY74eYhjTK/7/HZ4T1lLzyWmH8wVCeVE+cKpN2KnKifG1i3zaRIvCMuCwK6bFBzB1iwNEYp0PDRpfEmN71TmxdAyw8EzsrIQ3WiKY2dCZOB9VPyt9FvMJkurHxWrKr93FjAoTlzYI9apOYs41XZVLSN06mOCpEOrXgwedOO5RxoyRxexV9vmzxPKf098OzAQ/Uq6ZC/YzOtW37K7ShguifooB/qRm+fF6JTIKtS1ng6mtFvYGJAqBxvH3OXbXI5J4tk9XqQpP46gI4g/Y8cADNEPIh6zmsMBhncgcLGWm0w==',
    require => File['/home/larserik/.ssh'],
  }
}
