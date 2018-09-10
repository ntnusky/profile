# Storage pools for libvirt
# This class requires an empty LVM VG called "vmvg"
# to be present on your system
class profile::services::libvirt::pools {

  libvirt_pool { 'vmvg':
    ensure    => present,
    type      => 'logical',
    autostart => true,
    target    => '/dev/vmvg',
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
