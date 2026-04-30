# Mitigates CVE-2026-31431
class profile::baseconfig::copyfail {
  $mitigate = lookup('profile::mitigation::copyfail', {
    'default_value' => true,
    'value_type'    => Boolean, 
  })

  if($mitigate) {
    file { '/etc/modprobe.d/disable-algif.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'install algif_aead /bin/false',
      notify  => Exec['unload algif'],
    }

    exec { 'unload algif':
      command     => '/usr/sbin/rmmod algif_aead',
      refreshonly => true,
    }
  } else {
    file { '/etc/modprobe.d/disable-algif.conf':
      ensure  => absent,
      notify  => Exec['load algif'],
    }

    exec { 'load algif':
      command     => '/usr/sbin/modprobe algif_aead',
      refreshonly => true,
    }
  }
}
