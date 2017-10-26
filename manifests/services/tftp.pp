# This class installs a tftpserver and configures it to have its root at
# /var/lib/tftpboot.
class profile::services::tftp {
  $rootdir = hiera('profile::tftp::root', '/var/lib/tftpboot/') 
  $images = hiera('profile::pxe::images')

  include ::profile::services::dashboard::clients::tftp
  include ::profile::services::tftp::firewall

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

  file { "${rootdir}pxelinux.0":
    ensure  => 'file',
    source  => '/usr/lib/PXELINUX/pxelinux.0',
    require => Package['pxelinux'],
  }

  file { "${rootdir}ldlinux.c32":
    ensure  => 'file',
    source  => '/usr/lib/syslinux/modules/bios/ldlinux.c32',
    require => Package['syslinux'],
  }

  ::profile::services::tftp::image { $images : }
}
