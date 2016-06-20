class profile::tftpserver {
  class { '::tftp':
    directory => '/var/lib/tftpboot/',
  }
}
