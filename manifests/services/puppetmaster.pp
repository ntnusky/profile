# Installs and configures a puppetmaster 
class profile::services::puppetmaster {
  # Install the puppetmaster-integration for the dashboards.
  include ::profile::services::dashboard::install::onlycode

  $cnf = '/etc/machineadmin/settings.ini'

  $path = '/opt/machineadmin-code'
  cron { 'Dashboard-client puppet-environments':
    command => "${path}/clients/puppetEnvironmentUpdater.py ${cnf}",
    user    => 'root',
    minute  => '*',
  }
}
