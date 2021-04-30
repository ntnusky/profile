# Enable PostgreSQL backup to a external host
class profile::services::postgresql::backup::external {

  require ::profile::services::backup::sql

  cron { 'PostgreSQL external backup':
    command => '/usr/local/bin/external-sql-backup.sh',
    user    => 'root',
    hour    => '2',
    minute  => '30',
  }
}
