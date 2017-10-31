# Installs the puppetmaster with r10k.
class profile::services::puppet::server::install {
  require ::profile::services::dashboard::install

  $r10krepo = hiera('profile::puppet::r10k::repo')

  package { 'puppetserver':
    ensure => 'present',
  }

  class { 'r10k':
    remote => $r10krepo,
  }

  cron { 'Dashboard-client puppet-environments':
    command => '/opt/shiftleader/manage.py puppet_report',
    user    => 'root',
    minute  => '*',
  }
}
