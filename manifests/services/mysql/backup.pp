# Backups the database content of mysql
class profile::services::mysql::backup {

  $externa_backup = lookup('profile::mysql::backup::external', {
    'default_value' => false,
    'value_type'    => Boolean
  })

  file { '/usr/local/sbin/mysqlbackup.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/mysql/mysqlbackup.sh',
  }

  file { '/usr/local/sbin/mysqlbackupclean.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/mysql/mysqlbackupclean.py',
  }

  cron { 'Mysql database backup':
    command => '/usr/local/sbin/mysqlbackup.sh',
    user    => 'root',
    hour    => '*/3',
    minute  => '44',
  }

  cron { 'Mysql database backup cleaning':
    command => '/usr/local/sbin/mysqlbackupclean.py',
    user    => 'root',
    hour    => '1',
    minute  => '57',
  }

  if ($external_backup) {
    include ::profile::services::mysql::backup::external
  }
}
