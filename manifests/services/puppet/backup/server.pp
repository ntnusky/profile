# Make sure the puppetserver are not creating cabackups. 
class profile::services::puppet::backup::server {
  include ::profile::services::puppet::backup::folders

  cron { 'Puppet cabackup':
    ensure => absent,
  }
}
