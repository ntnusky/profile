# Blocks the loading of certail kmod-modules to mitigate the new stream of
# vulnerabilities like copyfail and dirtyfrag.
class profile::baseconfig::kmodblock {
  $blocklist = lookup('profile::kmod::blocklist', {
    'default_value' => [ 'algif_aead', 'esp4', 'esp6', 'rxrpc'],
    'value_type'    => Array[String],
  })
  $cleanup = lookup('profile::kmod::blocklist::cleanup', {
    'default_value' => ['algif'],
    'value_type'    => Array[String],
  })

  $blocklist.each | $module | {
    file { "/etc/modprobe.d/disable-${module}.conf":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "install ${module} /bin/false",
      notify  => Exec["unload ${module}"],
    }

    exec { "unload ${module}":
      command     => "/usr/sbin/rmmod ${module} 2> /dev/null || /bin/true",
      refreshonly => true,
    }
  }

  $cleanup.each | $module | {
    file { "/etc/modprobe.d/disable-${module}.conf":
      ensure  => absent,
    }
  }
}
