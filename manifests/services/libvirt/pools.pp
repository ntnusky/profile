# Storage pools for libvirt
# There should be created a lvm VG, and its name should be delivered trough
# hiera.
class profile::services::libvirt::pools {
  $poolname = hiera('profile::kvm::vmvg::name', false)

  if($poolname) {
    libvirt_pool { $poolname:
      ensure    => present,
      type      => 'logical',
      autostart => true,
      target    => "/dev/${poolname}",
    }
  }

  libvirt_pool { 'default':
    ensure => absent,
  }

  libvirt_pool { 'images':
    ensure => absent,
  }

  $installsensu = hiera('profile::sensu::install', true)
  if ($installsensu) {
    include ::profile::sensu::plugin::lvm
    sensu::subscription { 'lvm-checks': }
  }
}
