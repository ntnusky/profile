# Defines a cron job for automatic mail list generation
class profile::services::info::maillist {
  $mailfqdn = lookup('profile::info::maillist::fqdn')

  require ::ntnuopenstack::clients

  file { '/usr/local/bin/generateMailList.sh':
    ensure  => file,
    owner   => 'root',
    mode    => '0755',
    content => template('profile/generateMailList.erb'),
  }

  cron { 'maillist':
    command => '/usr/local/bin/generateMailList.sh 2>&1 /dev/null',
    user    => 'root',
    hour    => '*/2',
    minute  => '00',
  }

  file { "/var/www/${mailfqdn}/mail":
    ensure => directory,
    owner  => 'root',
    mode   => '0755',
  }
}
