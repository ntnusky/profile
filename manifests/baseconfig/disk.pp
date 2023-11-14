# Manipulates the servers disks if needed.
class profile::baseconfig::disk {
  $rootsize = lookup('profile::disk::root::size', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })
  $varsize = lookup('profile::disk::var::size', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })
  $swapsize = lookup('profile::disk::swap::size', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })

  if($rootsize) {
    logical_volume { 'rootfs':
      ensure       => present,
      volume_group => 'bootdisk',
      size         => $rootsize,
    }
  }

  if($varsize) {
    logical_volume { 'varfs':
      ensure       => present,
      volume_group => 'bootdisk',
      size         => $varsize,
    }
  }

  if($swapsize) {
    logical_volume { 'swap':
      ensure       => present,
      volume_group => 'bootdisk',
      size         => $swapsize,
    }
  }
}
