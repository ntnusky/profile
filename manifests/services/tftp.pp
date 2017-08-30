# This class installs a tftpserver and configures it to have its root at
# /var/lib/tftpboot.
class profile::services::tftp {
  class { '::tftp':
    directory => '/var/lib/tftpboot/',
    options   => '--secure',
  }
}
