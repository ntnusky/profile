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
  group { 'administrator':
    ensure => present,
    gid    => 701,
  }
  group { 'ntnuadmin':
    ensure => present,
    gid    => 702,
  }

  # Modify root's attributes
  file { '/root/.ssh':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  file { '/root/.bashrc':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('profile/bashrc.erb'),
  }

  file { '/root/.mailrc':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('profile/mailrc.erb'),
  }

  $keys = hiera('profile::user::root::keys', false)
  if($keys) {
    ::profile::baseconfig::createkey { $keys:
      username => 'root',
    }
  }
}
