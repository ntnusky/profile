# Installs mysql backup scripts
class profile::services::mysql::backup::scripts {
  file { '/usr/local/sbin/mysqlbackup.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/mysql/mysqlbackup.sh',
  }

  file { '/usr/local/sbin/mysqlbackup-remote.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/mysql/mysqlbackup-remote.sh',
  }

  file { '/usr/local/sbin/mysqlbackupclean.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/mysql/mysqlbackupclean.py',
  }

  file { '/usr/local/sbin/mysqlbackupclean-remote.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/mysql/mysqlbackupclean-remote.sh',
  }
}
