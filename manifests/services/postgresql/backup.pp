# Backups the database content of postgres
class profile::services::postgresql::backup {
  $management_if = hiera('profile::interfaces::management')
  $pgip = $facts['networking']['interfaces'][$management_if]['ip']

  file { '/usr/local/sbin/postgresbackup.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => template('puppet:///modules/profile/postgresbackup.sh.erb'),
  }

  file { '/usr/local/sbin/postgresbackupclean.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/postgres/postgresbackupclean.py',
  }

  cron { 'Postgres database backup':
    command => '/usr/local/sbin/postgresbackup.sh',
    user    => 'root',
    hour    => '*/3',
    minute  => '26',
  }

  cron { 'Postgres database backup cleaning':
    command => '/usr/local/sbin/postgresbackupclean.py',
    user    => 'root',
    hour    => '1',
    minute  => '14',
  }
}
