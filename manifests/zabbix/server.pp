# This class installs a zabbix-server and a zabbix-frontend
class profile::zabbix::server {
  $db_pass = lookup('profile::zabbix::database::password', String)

  $cert = lookup("profile::zabbix::web::cert")
  $key = lookup("profile::zabbix::web::key")

  include ::apache::mod::php
  include ::apache::mod::prefork
  include ::apache::mod::ssl

  file { '/etc/ssl/private/zabbix.crt':
    ensure    => 'present',
    content   => $cert,
    mode      => '0600',
    notify    => Service['httpd'],
  }

  file { '/etc/ssl/private/zabbix.key':
    ensure    => 'present',
    content   => $key,
    mode      => '0600',
    notify    => Service['httpd'],
    show_diff => false,
  }

  class { '::apache':
    mpm_module    => 'prefork',
    confd_dir     => '/etc/apache2/conf-enabled',
    default_vhost => false,
  }

  class { 'zabbix::server':
    database_type     => 'mysql',
    database_password => $db_pass,
  }

  class { 'zabbix::web':
    zabbix_url        => $zabbix_url,
    apache_use_ssl    => true,
    apache_ssl_cert   => '/etc/ssl/private/zabbix.crt',
    apache_ssl_key    => '/etc/ssl/private/zabbix.key',
    database_type     => 'mysql',
    database_password => $db_pass,
  }
}
