# Installs the script and cronjob for flushing tokens from the keystone
# database.
class profile::openstack::keystone::tokenflush {
  $token_flush_host = hiera('profile::keystone::tokenflush::host')

  file { '/usr/local/bin/keystone-token-flush.sh':
    ensure => file,
    source => 'puppet:///modules/profile/openstack/keystone-token-flush.sh',
    mode   => '0555',
  }

  if($::hostname == $token_flush_host) {
    cron { 'token-flush':
      command => '/usr/local/bin/keystone-token-flush.sh',
      user    => root,
      minute  => [10,40],
    }
  }
}
