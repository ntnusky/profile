# This class starts to configure sudo
class profile::baseconfig::sudo {
  # if purge::unmanaged is true we should purge all files in sudoers.d that is
  # not managed by puppet. If it is false we will only purge files with the
  # puppet-prefix (ie: files previously managed by puppet).
  $purge = lookup('profile::baseconfig::sudo::purge::unmanaged', {
    'default_value' => true,
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

  sudo::conf { 'sensu-client':
    priority => 15,
    source   => 'puppet:///modules/profile/sudo/sensu_sudoers',
  }

  sudo::conf { 'administrator':
    priority => 11,
    source   => 'puppet:///modules/profile/sudo/administrator_sudoers',
  }
}
