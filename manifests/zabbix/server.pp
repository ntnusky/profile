# This class installs a zabbix-server and a zabbix-frontend
class profile::zabbix::server {
  $db_pass = lookup('profile::zabbix::database::password', String)
  $db_manage = lookup('profile::zabbix::database::manage', {
    'default_value' => false,
    'value_type'    => Boolean,
  })
  $zabbix_version = lookup('profile::zabbix::version', {
    'default_value' => '7.0',
    'value_type'    => String,
  })
  $zabbix_web_server_name = lookup('profile::zabbix::web::server::name', { 
    'default_value' => $::fqdn,
    'value_type'    => String,
  })

  $cert = lookup("profile::zabbix::web::cert")
  $key = lookup("profile::zabbix::web::key")

  include ::profile::zabbix::deps

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

  ::profile::baseconfig::firewall::service::infra { 'zabbix-agents':
    port     => 10051,
    protocol => 'tcp',
  }

  class { 'zabbix::server':
    database_type     => 'mysql',
    database_password => $db_pass,
    hanodename        => $::fqdn,
    nodeaddress       => $::sl2['server']['primary_interface']['ipv4'],
    manage_database   => $db_manage,
    zabbix_version    => $zabbix_version,
    require           => Anchor['shiftleader::database::create'],
  }

  ::profile::baseconfig::firewall::service::management { 'zabbix-dashboard':
    port     => [ 80 , 443 ],
    protocol => 'tcp',
  }

  class { 'zabbix::web':
    apache_ssl_cert    => '/etc/ssl/private/zabbix.crt',
    apache_ssl_key     => '/etc/ssl/private/zabbix.key',
    apache_use_ssl     => true,
    database_password  => $db_pass,
    database_type      => 'mysql',
    default_vhost      => true,
    zabbix_url         => $::fqdn,
    zabbix_version     => $zabbix_version,
    zabbix_server_name => $zabbix_web_server_name,
    require            => [
      File['/etc/ssl/private/zabbix.crt'],
      File['/etc/ssl/private/zabbix.key'],
    ],
  }
}
