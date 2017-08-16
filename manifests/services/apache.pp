# This class installs and configures a simple apache webserver, and configures a
# vhost for the fqdn of the host
class profile::services::apache {
  class { '::apache':
    mpm_module => 'prefork',
    confd_dir  => '/etc/apache2/conf-enabled'
  }

  package { 'libcgi-pm-perl':
    ensure => present,
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

  require ::profile::baseconfig::firewall 

  firewall { '504 accept incoming HTTP, HTTPS':
    proto  => 'tcp',
    dport  => [80,443],
    action => 'accept',
  }
}
