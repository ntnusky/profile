# Backups the database content of mysql
class profile::services::mysql::backup {
  $external_backup = lookup('profile::mysql::backup::external', {
    'default_value' => false,
    'value_type'    => Boolean
  })
  $schedule = lookup('profile::mysql::backup::schedule', {
    'default_value' => 'trihoral',
    'value_type'    => Enum['trihoral', 'daily', 'weekly'],
  })

  include ::profile::services::mysql::backup::scripts

  case $schedule {
    # Run every three hours
    'trihoral': {
      $hour = '*/3'
      $day = '*'
    }

    # Run daily at a random time within 00:00 and 06:59
    'daily': {
      $hour = fqdn_rand(6)
      $day = '*'
    }

    # Run at sundays at a random time within 00:00 and 06:59
    'weekly': {
      $hour = fqdn_rand(6)
      $day = '0'
    }
  }

  if ($external_backup) {
    include ::profile::zabbix::agent::mysql

    $backup_command = '/usr/local/sbin/mysqlbackup-remote.sh'
    $clean_command = '/usr/local/sbin/mysqlbackupclean-remote.sh'
  } else {
    $backup_command = '/usr/local/sbin/mysqlbackup.sh'
    $clean_command = '/usr/local/sbin/mysqlbackupclean.py /var/backups'
  }

  cron { 'Mysql database backup':
    command => $backup_command, 
    hour    => $hour, 
    minute  => fqdn_rand(60, "${::hostname}-backup"), 
    user    => 'root',
    weekday => $day,
  }

  cron { 'Mysql database backup cleaning':
    command => $clean_command, 
    hour    => fqdn_rand(6) + 8, 
    minute  => fqdn_rand(60, "${::hostname}-cleaning"), 
    user    => 'root',
    weekday => $day,
  }
}
