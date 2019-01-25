# Defines the bird service for ipv6
class profile::bird::service::ipv6 {
  include ::profile::bird::install

  service { 'bird6':
    ensure  => 'running',
    enable  => true,
    require => Package['bird'],
  }
}
