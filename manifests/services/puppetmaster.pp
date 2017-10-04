# Installs and configures a puppetmaster 
class profile::services::puppetmaster {
  include ::profile::services::dashboard::install
  include ::profile::services::puppetmaster::keepalived

  $puppetdb_hostname = hiera('profile::puppetdb::hostname')
  $usepuppetdb = hiera('profile::puppetdb::masterconfig', true)
  $puppetca = hiera('profile::puppet::caserver')

  $cnf = '/etc/machineadmin/settings.ini'

  package { 'puppetserver':
    ensure => 'present',
  }

  if($puppetca == $::fqdn) {
    $enabled = 'present'
    $disabled = 'absent'
  } else {
    $enabled = 'absent'
    $disabled = 'present'
  }

  $pfx = 'puppetlabs.services.ca.certificate-authority-'
  ini_setting { 'Puppetmaster ca enable':
    ensure            => $enabled,
    path              => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
    setting           => "${pfx}service/certificate-authority-service",
    key_val_separator => '',
  }
  $setting = "${pfx}disabled-service/certificate-authority-disabled-service"
  ini_setting { 'Puppetmaster ca disable':
    ensure            => $disabled,
    path              => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
    setting           => $setting,
    key_val_separator => '',
  }

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
