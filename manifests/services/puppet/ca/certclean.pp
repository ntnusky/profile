# Configures the puppetmaster to use hiera, and set up hiera replication between
# puppet masters
class profile::services::puppet::ca::certclean {
  $adminmail = lookup('profile::admin::maillist', {
    'value_type'    => String,
    'default_value' => 'root',
  })

  $collection = lookup('profile::puppet::collection', {
    'value_type'    => String,
  })

  if($collection == 'puppet7) {
    $script = 'puppetcert_clean_v7.sh'
  } else {
    $script = 'puppetcert_clean.sh'
  }

  file { '/usr/local/sbin/puppetcert_clean.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/profile/puppet/${script}",
  }

  cron { 'Puppet cleaning certificates':
    command     => '/usr/local/sbin/puppetcert_clean.sh',
    environment => "MAILTO=${adminmail}",
    minute      => '*',
    user        => 'root',
  }
}
