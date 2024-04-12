# This class installs and configures a simple apache webserver, and configures a
# vhost for the fqdn of the host
class profile::services::apache {
  if($::sl2) {
    $default = $::sl2['server']['primary_interface']['name']
  } else {
    $default = undef
  }

  $management_if = lookup('profile::interfaces::management', {
    'default_value' => $default, 
    'value_type'    => String,
  })
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

  $sl_version = lookup('profile::shiftleader::major::version', {
    'default_value' => 1,
    'value_type'    => Integer,
  })

  require ::profile::services::apache::server
  include ::profile::services::apache::logging

  if ( $management_netv6 ) {
    $management_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']
    $ip = concat([], $management_ipv4, $management_ipv6)
  } else {
    $ip = [$management_ipv4]
  }

  # The SL1 roles load wsgi themselves.
  if($sl_version != 1) {
    include ::apache::mod::wsgi
    $vhost_extra = {}
  } else {
    $vhost_extra = {
      'ip' => $ip,
    }
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
    port          => 80,
    add_listen    => false,
    docroot       => $default_docroot,
    docroot_owner => 'www-data',
    docroot_group => 'www-data',
    *             => $vhost_extra,
  }

  include ::apache::mod::rewrite
  include ::apache::mod::prefork
  include ::apache::mod::ssl
  include ::profile::services::apache::firewall
}
