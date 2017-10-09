# Manages the puppetserver service
class profile::services::puppetmaster::service {
  service { 'puppetserver':
    ensure  => 'running',
    enable  => true,
    require => Package['puppetserver'],
  }
}
