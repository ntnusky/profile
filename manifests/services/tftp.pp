# This class installs a tftpserver and configures it to have its root at
# /var/lib/tftpboot.
class profile::services::tftp {
  $rootdir = lookup('profile::tftp::root', {
    'default_value' => '/var/lib/tftpboot/',
    'value_type'    => Stdlib::Unixpath,
  })

  $sl_version = lookup('profile::shiftleader::major::version', {
    'default_value' => 1,
    'value_type'    => Integer,
  })

  include ::profile::services::tftp::acl
  include ::profile::services::tftp::firewall

  # If we use shiftleader1 we need to allow for external OMAPI requests from the
  # shiftleader servers.
  # TODO: Remove SL1 when we dont use it anymore 
  if($sl_version == 1) {
    include ::profile::services::dashboard::clients::tftp
  } else {
    include ::shiftleader::worker::tftp
  }

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
  package { ['syslinux', 'syslinux-efi', 'pxelinux']:
    ensure => 'present',
  }

  file { $rootdir:
    ensure => directory, 
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${rootdir}pxelinux.0":
    ensure  => 'file',
    source  => '/usr/lib/PXELINUX/pxelinux.0',
    require => [ Package['pxelinux'], File[$rootdir] ],
  }

  file { "${rootdir}ldlinux.c32":
    ensure  => 'file',
    source  => '/usr/lib/syslinux/modules/bios/ldlinux.c32',
    require => [ Package['syslinux'], File[$rootdir] ],
  }

  file { "${rootdir}ldlinux.e64":
    ensure  => 'file',
    source  => '/usr/lib/syslinux/modules/efi64/ldlinux.e64',
    require => [ Package['syslinux-efi'], File[$rootdir] ],
  }

  file { "${rootdir}syslinux.efi":
    ensure  => 'file',
    source  => '/usr/lib/SYSLINUX.EFI/efi64/syslinux.efi',
    require => [ Package['syslinux-efi'], File[$rootdir] ],
  }
}
