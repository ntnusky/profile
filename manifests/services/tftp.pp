# This class installs a tftpserver and configures it to have its root at
# /var/lib/tftpboot.
class profile::serices::tftpserver {
  class { '::tftp':
    directory => '/var/lib/tftpboot/',
    inetd     => true,
    options   => '--secure',
  }
}
