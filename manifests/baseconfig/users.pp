# This class configures users based on information in hiera
class profile::baseconfig::users {
  # Configure users as instructed in hiera.
  $users = hiera('profile::users', false)
  if($users) {
    profile::baseconfig::createuser { $users: }
  }

  # Create the users group
  group { 'users':
    ensure => present,
    gid    => 700,
  }

  # Modify root's attributes
  file { '/root/.ssh':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  ssh_authorized_key { 'root@manager':
    user    => 'root',
    type    => 'ssh-rsa',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCdvmiR2cTIKgxSHfIADwb808QDnqx83VxsqNlmRYx3CopAbrXMF/84WAMkYcumnG4y7qIhCbkLfMlaB4Ym1mutmQWWxUVnnLGUsxoeZxPqbeBcmkwSseahEl1X/yg65H0rh+9bj6gCLbNdORM6sqAVlzdHpus3VppVdFr8Wq1Zm37rh4dI2SWfMDrND9RfZ2Eirmg3HhhF+MAiADo4itGbsR7ALJWf0V6kTFr2sgDZ2fNZ8xDO52bS1LxJK9s0zL+ilyi+vhGNCv00yrYe9CQAGG4P2C/sDNyDt6eaEg4c5eCgba1mfjSrFlIZg6ZGaxkJ5IAli71oN+honP7z0XGL',
    require => File['/root/.ssh'],
  }

  file { '/root/.bashrc':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/profile/.bashrc',
  }
}
