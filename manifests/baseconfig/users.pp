# This class configures users based on information in hiera
class profile::baseconfig::users {
  # Get user-configuration from hiera
  $users = lookup('profile::user', {
    'default_value' => {},
    'merge'         => 'deep',
    'value_type'    => Hash,
  })

  # Create the users group
  group { 'users':
    ensure => present,
    gid    => 700,
  }
  group { 'administrator':
    ensure => present,
    gid    => 701,
  }

  $users.each | $username, $data | {
    $ensure = pick($data['ensure'], 'present')
    $homedir = "/home/${username}"

    user { $username:
      ensure         => $ensure,
      gid            => 'users',
      groups         => pick($data['groups'], []),
      home           => $homedir,
      managehome     => true,
      password       => $data['hash'],
      purge_ssh_keys => pick($data['purge_keys'], true),
      require        => Group['users'],
      shell          => '/bin/bash',
      uid            => $data['uid'],
    }
    
    ::profile::baseconfig::alias { $username : 
      require => User[$username],
    }

    if ( $ensure == 'present' ) {
      file { "${homedir}/.ssh":
        ensure  => 'directory',
        owner   => $username,
        group   => 'users',
        mode    => '0700',
        require => User[$username],
      }

      $data['keys'].each | $name, $keydata | {
        ssh_authorized_key { $name:
          user    => $username,
          type    => $keydata['type'],
          key     => $keydata['key'],
          require => File["${homedir}/.ssh"],
        }
      }
    }
  }

  ::profile::baseconfig::alias { 'root' : }

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

  # We should really not do this... TODO: Stop logging in as root on all
  # platforms...
  $rootkeys = lookup('profile::user::root::keys', {
    'default_value' => [],
    'value_type'    => Array[String],
  })
  $rootkeys.each | $keyname | {
    $key = lookup("profile::user::root::key::${keyname}", String)

    ssh_authorized_key { $keyname:
      user    => 'root',
      type    => 'ssh-rsa',
      key     => $key,
      require => File['/root/.ssh'],
    }
  }
}
