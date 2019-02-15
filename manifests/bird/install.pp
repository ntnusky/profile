# Installs the bird routing-daemon
class profile::bird::install {
  package { 'bird':
    ensure => 'present',
  }
}
