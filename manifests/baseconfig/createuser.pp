# Creates user 'larserik'
define profile::baseconfig::createuser {
  $uid = hiera("profile::user::${name}::uid")
  $ensure = hiera("profile::user::${name}::ensure", 'present')
  $groups = hiera("profile::user::${name}::groups", [])
  $hash = hiera("profile::user::${name}::hash", '*')
  $keys = hiera("profile::user::${name}::keys", false)

  user { $name:
    ensure     => $ensure,
    gid        => 'users',
    require    => Group['users'],
    groups     => $groups,
    uid        => $uid,
    shell      => '/bin/bash',
    home       => "/home/${name}",
    managehome => true,
    password   => $hash,
  }

  if ( $ensure == 'present' ) {
    file { "/home/${name}/.ssh":
      ensure  => 'directory',
      owner   => $name,
      group   => 'users',
      mode    => '0700',
      require => User[$name],
    }
  
    if($keys) {
      ::profile::baseconfig::createkey { $keys:
        username => $name,
      }
    }
  }
}
