# This class installs a zabbix-server and a zabbix-frontend
class profile::zabbix::server {
  $db_pass = lookup('profile::zabbix::database::password', String)
  $db_manage = lookup('profile::zabbix::database::manage', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  $cert = lookup("profile::zabbix::web::cert")
  $key = lookup("profile::zabbix::web::key")

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

  class { 'zabbix::server':
    database_type     => 'mysql',
    database_password => $db_pass,
    manage_database   => $db_manage,
  }

  ::profile::baseconfig::firewall::service::management { 'zabbix-dashboard':
    port     => [ 80 , 443 ],
    protocol => 'tcp',
  }

  class { 'zabbix::web':
    zabbix_url        => $::fqdn,
    apache_use_ssl    => true,
    apache_ssl_cert   => '/etc/ssl/private/zabbix.crt',
    apache_ssl_key    => '/etc/ssl/private/zabbix.key',
    database_type     => 'mysql',
    database_password => $db_pass,
    default_vhost     => true,
    require           => [
      File['/etc/ssl/private/zabbix.crt'],
      File['/etc/ssl/private/zabbix.key'],
    ],
  }
}
