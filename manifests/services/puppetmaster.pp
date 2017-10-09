# Installs and configures a puppetmaster 
class profile::services::puppetmaster {
  include ::profile::services::dashboard::install
  include ::profile::services::puppetmaster::keepalived

  $puppetdb_hostname = hiera('profile::puppetdb::hostname')
  $usepuppetdb = hiera('profile::puppetdb::masterconfig', true)
  $puppetca = hiera('profile::puppet::caserver')
  $r10krepo = hiera('profile::puppet::r10k::repo')

  $cnf = '/etc/machineadmin/settings.ini'

  package { 'puppetserver':
    ensure => 'present',
  }
  service { 'puppetserver':
    ensure  => 'running',
    enable  => true,
    require => Package['puppetserver'],
  }

  class { 'r10k':
    remote => $r10krepo,
  }

  @@ssh_authorized_key { "puppetmaster-${::fqdn}":
    user    => 'root',
    type    => 'ssh-rsa',
    key     => $::facts['ssh']['rsa']['key'],
    tag     => 'puppetmaster-hostkeys',
    require => File['/root/.ssh'],
  }
  Ssh_authorized_key <<| tag == 'puppetmaster-hostkeys' |>>

  file { '/usr/local/sbin/pull_hiera.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/puppet/pull_hiera.sh',
  }

  if($puppetca == $::fqdn) {
    $template = 'ca.enabled.cfg'
  } else {
    $template = 'ca.disabled.cfg'
  }

  file { '/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem':
    ensure  => 'link',
    owner   => 'puppet',
    group   => 'puppet',
    target  => '/etc/puppetlabs/puppet/ssl/crl.pem',
    replace => false,
    notify  => Service['puppetserver'],
    require => File['/etc/puppetlabs/puppet/ssl/ca'],
  }

  file { '/etc/puppetlabs/puppet/ssl/ca':
    ensure  => 'directory',
    mode    => '0755',
    owner   => 'puppet',
    group   => 'puppet',
    require => Package['puppetserver'],
  }

  file { '/etc/puppetlabs/puppetserver/services.d/ca.cfg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/profile/puppet/${template}",
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  cron { 'Dashboard-client puppet-environments':
    command => '/opt/machineadmin/manage.py puppet_report',
    user    => 'root',
    minute  => '*',
  }

  cron { 'Puppet hieradata sync':
    command => '/usr/local/sbin/pull_hiera.sh',
    user    => 'root',
    minute  => '*',
  }

  ini_setting { 'Puppetmaster autosign':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'autosign',
    value   => '/opt/machineadmin/clients/puppetAutosign.sh',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  ini_setting { 'Puppetmaster node_terminus':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'node_terminus',
    value   => 'exec',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  ini_setting { 'Puppetmaster enc':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'external_nodes',
    value   => '/opt/machineadmin/clients/puppetENC.sh',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  if($usepuppetdb) {
    class { 'puppetdb::master::config':
      puppetdb_server => $puppetdb_hostname,
    }
  }
}
