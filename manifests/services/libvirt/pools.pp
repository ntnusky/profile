# Storage pools for libvirt
# There should be created a lvm VG, and its name should be delivered trough
# hiera.
class profile::services::libvirt::pools {
  $poolname = lookup('profile::kvm::vmvg::name', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })

  $volumegroups = lookup('profile::kvm::vgs', {
    'default_value' => [],
    'value_type'    => Array[String],
  })

  if($poolname) {
    $vg_real = $volumegroups + [ $poolname ]
  } else {
    $vg_real = $volumegroups
  }

  $vg_real.each | $vg | {
    libvirt_pool { $vg:
      ensure    => present,
      type      => 'logical',
      autostart => true,
      target    => "/dev/${vg}",
    }
  }

  libvirt_pool { 'default':
    ensure => absent,
  }

  libvirt_pool { 'images':
    ensure => absent,
  }
}
