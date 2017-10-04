# This class installs a tftpserver and configures it to have its root at
# /var/lib/tftpboot.
class profile::services::tftp {
  $rootdir = hiera('profile::tftp::root', '/var/lib/tftpboot/') 

  include ::profile::services::dashboard::clients::tftp

  # Install and configure the tftp server.
  class { '::tftp':
    directory => $rootdir,
    options   => '--secure',
  }
  
  # A tftp client is handy for testing.
  package { 'tftp-hpa':
    ensure => 'present',
  }

  # Set up the tftp-boot directory
  package { ['syslinux', 'pxelinux']:
    ensure => 'present',
  }

  file { '/var/lib/tftpboot/pxelinux.0':
    ensure  => 'link',
    target  => '/usr/lib/PXELINUX/pxelinux.0',
    require => Package['pxelinux'],
  }

  file { '/var/lib/tftpboot/ldlinux.c32':
    ensure  => 'link',
    target  => '/usr/lib/syslinux/modules/bios/ldlinux.c32',
    require => Package['syslinux'],
  }
}
