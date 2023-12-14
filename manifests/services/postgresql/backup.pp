# Backups the database content of postgres
class profile::services::postgresql::backup {
  # TODO: Stop looking for the management-IP in hiera, and simply just take it
  # from SL.
  $management_if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })
  $pgip = $facts['networking']['interfaces'][$management_if]['ip']
  $external_backup = lookup('profile::postgresql::backup::external', {
    'default_value' => false,
    'value_type'    => Boolean
  })

  file { '/usr/local/sbin/postgresbackup.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/postgres/postgresbackup.sh',
  }

  file { '/usr/local/sbin/postgresbackupclean.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/postgres/postgresbackupclean.py',
  }

  cron { 'Postgres database backup':
    command => "/usr/local/sbin/postgresbackup.sh ${pgip}",
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

  if ($external_backup) {
    include ::profile::services::postgresql::backup::external
  }
}
