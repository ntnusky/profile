#Installs and configures a zabbix-proxy
class profile::zabbix::proxy {
  $zabbix_version = lookup('profile::zabbix::version', {
    'default_value' => '7.0',
    'value_type'    => String,
  })
  $servers = lookup('profile::zabbix::proxy::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  file { '/var/cache/zabbix-proxy':
    ensure  => directory,
    mode    => '0750',
    owner   => 'zabbix',
    group   => 'zabbix',
    before  => Class['zabbix::database::sqlite'],
    require => Package['zabbix-proxy-sqlite3'],
  }

  ::profile::baseconfig::firewall::service::custom { 'zabbix-proxy':
    port     => 10051,
    protocol => 'tcp',
    v4source => $servers.map | $s | { "${s}/32" },
  }

  class { '::zabbix::proxy':
    database_type      => 'sqlite',
    database_name      => '/var/cache/zabbix-proxy/zabbixproxy.db',
    mode               => '1',
    startipmipollers   => 3,
    zabbix_server_host => join($servers, ','),
    zabbix_version     => $zabbix_version,
  }

  ::sudo::conf { 'zabbix-proxy_sudoers':
    priority => 15,
    source   => 'puppet:///modules/profile/sudo/zabbix-proxy_sudoers',
  }
}
