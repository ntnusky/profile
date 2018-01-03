# This class installs and configures a simple apache webserver, and configures a
# vhost for the fqdn of the host
class profile::services::apache {
  $management_if = hiera('profile::interfaces::management')
  $management_ipv4 = $::facts['networking']['interfaces'][$management_if]['ip']
  $management_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']

  class { '::apache':
    mpm_module => 'prefork',
    confd_dir  => '/etc/apache2/conf-enabled'
  }

  package { 'libcgi-pm-perl':
    ensure => present,
  }

  apache::listen { "${management_ipv4}:80": }
  apache::listen { "[${management_ipv6}]:80": }

  apache::vhost { "${::fqdn} http":
    servername    => $::fqdn,
    port          => '80',
    ip            => concat([], $management_ipv4, $management_ipv6),
    add_listen    => false
    docroot       => "/var/www/${::fqdn}",
    docroot_owner => 'www-data',
    docroot_group => 'www-data',
  }


  include ::apache::mod::rewrite
  include ::apache::mod::prefork
  include ::apache::mod::php
  include ::apache::mod::ssl
  include ::profile::services::apache::firewall

}
