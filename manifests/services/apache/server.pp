# This class installs and configures a simple apache webserver, and configures a
# vhost for the fqdn of the host
class profile::services::apache::server {
  class { '::apache':
    mpm_module    => 'prefork',
    confd_dir     => '/etc/apache2/conf-enabled',
    default_vhost => false,
  }
}
