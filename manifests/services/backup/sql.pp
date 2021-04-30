# Install script for MySQL/PostgreSQL external backup
class profile::services::backup::sql {
  file { '/usr/local/bin/external-sql-backup.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/utilities/external-sql-backup.sh'
  }
}
