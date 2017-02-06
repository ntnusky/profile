# Creates user 'larserik'
define profile::baseconfig::createuser {
  $uid = hiera("profile::user::${name}::uid")
  $groups = hiera("profile::user::${name}::groups")
  $hash = hiera("profile::user::${name}::hash")
  $keys = hiera("profile::user::${name}::keys", false)

  user { $name:
    ensure     => present,
    gid        => 'users',
    require    => Group['users'],
    groups     => $groups,
    uid        => $uid,
    shell      => '/bin/bash',
    home       => "/home/${name}",
    managehome => true,
    password   => $hash,
  }
  
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
