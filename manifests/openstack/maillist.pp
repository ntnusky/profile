# Defines a cron job for automatic mail list generation
class profile::openstack::maillist {

  file { '/usr/local/bin/generateMailList.sh':
    ensure  => file,
    owner   => 'root',
    mode    => '0755',
    content => template('profile/generateMailList.erb'),
  }

  cron { 'maillist':
    command => '/usr/local/bin/generateMailList.sh',
    user    => 'root',
    hour    => '*/2',
  }
}
