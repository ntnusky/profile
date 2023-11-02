# Installs duo 
class profile::baseconfig::duo::install {
  include profile::baseconfig::duo::apt

  package { 'duo-unix':
    ensure  => present,
    require => Exec['apt_update'],
  }
}
