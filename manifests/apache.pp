# This class installs and configures a simple apache webserver, and configures a
# vhost for the fqdn of the host
class profile::apache {
  class { '::apache':
    mpm_module    => 'prefork',
    confd_dir     => '/etc/apache2/conf-enabled'
  }

  apache::vhost { "${::fqdn} http":
    servername    => $::fqdn,
    port          => '80',
    docroot       => "/var/www/${::fqdn}",
    docroot_owner => 'www-data',
    docroot_group => 'www-data',
  }

  include ::apache::mod::rewrite
  include ::apache::mod::prefork
  include ::apache::mod::php
  include ::apache::mod::ssl
}