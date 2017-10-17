# Configures backup of certificates.
class profile::services::puppet::backup::ca {
  include ::profile::services::puppet::backup::folders

  file { '/usr/local/sbin/cabackup.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/puppet/cabackup.sh',
  }

  cron { 'Puppet cabackup':
    command => '/usr/local/sbin/cabackup.sh',
    user    => 'root',
    minute  => '*',
  }
}
