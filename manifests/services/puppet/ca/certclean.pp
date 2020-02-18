# Configures the puppetmaster to use hiera, and set up hiera replication between
# puppet masters
class profile::services::puppet::ca::certclean {
  $adminmail = lookup('profile::admin::maillist', {
    'value_type'    => String,
    'default_value' => 'root',
  })

  file { '/usr/local/sbin/puppetcert_clean.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/puppet/puppetcert_clean.sh',
  }

  cron { 'Puppet cleaning certificates':
    command     => '/usr/local/sbin/puppetcert_clean.sh',
    environment => "MAILTO=${adminmail}",
    minute      => '*',
    user        => 'root',
  }
}
