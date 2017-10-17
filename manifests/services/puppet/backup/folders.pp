# Configures folders where the puppetca can store its backup.
class profile::services::puppet::backup::folders {
  file { '/var/opt/puppet':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  @@file { "/var/opt/puppet/${::hostname}":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    tag    => 'puppetserver-backup',
  }

  File <<| tag == 'puppetserver-backup' |>>
}
