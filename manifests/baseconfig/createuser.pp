# Creates user based on lots of keys in hiera. 
define profile::baseconfig::createuser {
  $uid = lookup("profile::user::${name}::uid", Integer)
  $ensure = lookup("profile::user::${name}::ensure", {
    'value_type'    => String,
    'default_value' => 'present',
  })
  $groups = lookup("profile::user::${name}::groups", {
    'value_type'    => Array[String],
    'default_value' => [],
  })
  $hash = lookup("profile::user::${name}::hash", {
    'value_type'    => String,
    'default_value' => '*',
  })
  $keys = lookup("profile::user::${name}::keys", {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })
  $purge_keys = lookup("profile::user::${name}::purge::keys", {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  user { $name:
    ensure         => $ensure,
    gid            => 'users',
    groups         => $groups,
    home           => "/home/${name}",
    managehome     => true,
    password       => $hash,
    purge_ssh_keys => $purge_keys,
    require        => Group['users'],
    shell          => '/bin/bash',
    uid            => $uid,
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
