# This class installs a tftpserver and configures it to have its root at
# /var/lib/tftpboot.
class profile::services::tftp {
  $rootdir = lookup('profile::tftp::root', {
    'default_value' => '/var/lib/tftpboot/',
    'value_type'    => Stdlib::Unixpath,
  })

  include ::profile::services::tftp::acl
  include ::profile::services::tftp::firewall
  include ::shiftleader::worker::tftp

  # Install and configure the tftp server.
  class { '::tftp':
    root                    => $rootdir,
    manage_syslinux_package => false,
  }

  # TODO: Remove this purge at a later release
  package { 'xinetd':
    ensure => 'purged',
  }

  # A tftp client is handy for testing.
  package { 'tftp-hpa':
    ensure => 'present',
  }

  # Set up the tftp-boot directory
  package { ['syslinux', 'syslinux-common', 'syslinux-efi', 'pxelinux']:
    ensure => 'present',
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
