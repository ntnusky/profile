# Installs and configures a puppetmaster 
class profile::services::puppetmaster {
  include ::profile::services::dashboard::install
  include ::profile::services::puppetmaster::keepalived

  $puppetdb_hostname = hiera('profile::puppetdb::hostname')
  $usepuppetdb = hiera('profile::puppetdb::masterconfig', true)

  $cnf = '/etc/machineadmin/settings.ini'

  cron { 'Dashboard-client puppet-environments':
    command => "/opt/machineadmin/clients/puppetEnvironmentUpdater.py ${cnf}",
    user    => 'root',
    minute  => '*',
  }

  ini_setting { 'Puppetmaster autosign':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'autosign',
    value   => '/opt/machineadmin/clients/puppetAutosign.sh',
  }

  ini_setting { 'Puppetmaster node_terminus':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'node_terminus',
    value   => 'exec',
  }

  ini_setting { 'Puppetmaster enc':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'external_nodes',
    value   => '/opt/machineadmin/clients/puppetENC.sh',
  }

  if($usepuppetdb) {
    class { 'puppetdb::master::config':
      puppetdb_server => $puppetdb_hostname,
    }
  }
}
