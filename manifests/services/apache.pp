# This class installs and configures a simple apache webserver, and configures a
# vhost for the fqdn of the host
class profile::services::apache {
  include ::apache::mod::rewrite
  include ::apache::mod::prefork
  include ::apache::mod::php
  include ::apache::mod::ssl
  include ::profile::services::apache::firewall

  class { '::apache':
    mpm_module => 'prefork',
    confd_dir  => '/etc/apache2/conf-enabled'
  }

  package { 'libcgi-pm-perl':
    ensure => present,
  }
}
