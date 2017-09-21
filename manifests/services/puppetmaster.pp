# Installs and configures a puppetmaster 
class profile::services::puppetmaster {
  include ::profile::services::dashboard::install

  $cnf = '/etc/machineadmin/settings.ini'

  cron { 'Dashboard-client puppet-environments':
    command => "/opt/machineadmin/clients/puppetEnvironmentUpdater.py ${cnf}",
    user    => 'root',
    minute  => '*',
  }
}
