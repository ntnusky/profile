# Manages the puppetserver service
class profile::services::puppet::server::service {
  service { 'puppetserver':
    ensure  => 'running',
    enable  => true,
    require => Package['puppetserver'],
  }
}
