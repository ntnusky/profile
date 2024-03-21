# Remove cron-jobs for ShiftLeader1
class profile::services::dashboard::clients::purge {
  cron { 'Dashboard-client puppet report clean':
    ensure => absent,
  }
  cron { 'Dashboard-client tftp':
    ensure => absent,
  }
  cron { 'Dashboard-client tftpimages':
    ensure => absent,
  }
}
