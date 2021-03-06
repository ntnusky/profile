# Enable MySQL backup to a external host
class profile::services::mysql::backup::external {

  require ::profile::services::backup::sql

  cron { 'MySQL external backup':
    command => '/usr/local/bin/external-sql-backup.sh',
    user    => 'root',
    hour    => '2',
    minute  => '00',
  }
}
