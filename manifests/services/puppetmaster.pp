# Installs and configures a puppetmaster 
class profile::services::puppetmaster {
  # Install the puppetmaster-integration for the dashboards.
  include ::profile::services::dashboard::install::onlycode

  $cnf = '/etc/machineadmin/settings.ini'

  $path = '/opt/machineadmin-code'
  cron { 'Dashboard-client puppet-environments':
    command => "clients/puppetEnvironmentUpdater.py ${cnf}",
    path    => "${path}",
    user    => 'root',
    minute  => '*',
  }
}
