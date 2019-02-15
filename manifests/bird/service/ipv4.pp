# Defines the bird service
class profile::bird::service::ipv4 {
  include ::profile::bird::install

  service { 'bird':
    ensure  => 'running',
    enable  => true,
    require => Package['bird'],
  }
}
