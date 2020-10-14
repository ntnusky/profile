# This class installs and configures a simple apache webserver, and configures a
# vhost for the fqdn of the host
class profile::services::apache {
  $management_if = lookup('profile::interfaces::management', String)
  $default_docroot = lookup('profile::apache::vhost::default::docroot', {
    'value_type'    => Stdlib::Absolutepath,
    'default_value' => "/var/www/${::fqdn}",
  })

  $management_netv6 = lookup('profile::networks::management::ipv6::prefix', {
    'value_type'    => Variant[Stdlib::IP::Address::V6::CIDR, Boolean],
    'default_value' => false,
  })
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ipv4 = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $mip,
  })

  if ( $management_netv6 ) {
    $management_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']
    $ip = concat([], $management_ipv4, $management_ipv6)
  } else {
    $ip = [$management_ipv4]
  }

  class { '::apache':
    mpm_module    => 'prefork',
    confd_dir     => '/etc/apache2/conf-enabled',
    default_vhost => false,
  }

  package { 'libcgi-pm-perl':
    ensure => present,
  }

  apache::listen { "${management_ipv4}:80": }
  if ( $management_netv6 ) {
    apache::listen { "[${management_ipv6}]:80": }
  }

  apache::vhost { "${::fqdn}-http":
    servername    => $::fqdn,
    port          => '80',
    ip            => $ip,
    add_listen    => false,
    docroot       => $default_docroot,
    docroot_owner => 'www-data',
    docroot_group => 'www-data',
  }

  include ::apache::mod::rewrite
  include ::apache::mod::prefork
  include ::apache::mod::php
  include ::apache::mod::ssl
  include ::profile::services::apache::firewall
}
