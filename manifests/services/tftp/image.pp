# Installs a TFTP image and prepares it for netboot
define profile::services::tftp::image {
  $rootdir = hiera('profile::tftp::root', '/var/lib/tftpboot/')
  $kernel = hiera("profile::pxe::${name}::kernel")
  $initrd = hiera("profile::pxe::${name}::initrd")

  file { "${rootdir}${name}":
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file {"${rootdir}${name}/initrd.gz":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $initrd,
    require => File["${rootdir}${name}"],
  }

  file {"${rootdir}${name}/linux":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $kernel,
    require => File["${rootdir}${name}"],
  }
}
