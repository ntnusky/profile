# This class starts to configure sudo
class profile::baseconfig::sudo {
  # if purge::unmanaged is true we should purge all files in sudoers.d that is
  # not managed by puppet. If it is false we will only purge files with the
  # puppet-prefix (ie: files previously managed by puppet).
  $purge = lookup('profile::baseconfig::sudo::purge::unmanaged', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  $use_old_sudo = lookup('profile::baseconfig::sudo::use_old_suo', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  if($purge) {
    $opts = {}
  } else {
    $opts = { 'purge_ignore' => '[!puppet_]*' }
  }

  class { '::sudo':
    prefix => 'puppet_',
    *      => $opts,
  }

  sudo::conf { 'insults':
    priority => 10,
    content  => 'Defaults	insults',
  }

  sudo::conf { 'administrator':
    priority => 11,
    source   => 'puppet:///modules/profile/sudo/administrator_sudoers',
  }

  if( versioncmp($facts['os']['release']['major'], '26.04') >= 0 ) {
    if($use_old_sudo) {
      alternatives { 'sudo':
        path => '/usr/bin/sudo.ws',
      }
    }
    else {
      alternatives { 'sudo':
        path => '/usr/lib/cargo/bin/sudo',
      }
    }
  }
}
