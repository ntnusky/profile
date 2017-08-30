# This class installs a tftpserver and configures it to have its root at
# /var/lib/tftpboot.
class profile::services::tftp {
  # Install and configure the tftp server.
  class { '::tftp':
    directory => '/var/lib/tftpboot/',
    options   => '--secure',
  }
  
  # A tftp client is handy for testing.
  package { 'tftp-hpa':
    ensure => 'present',
  }
}
