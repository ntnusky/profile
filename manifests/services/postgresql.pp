# This class installs and configures the postgresql server
class profile::services::postgresql {
  contain profile::services::postgresql::backup
  contain profile::services::postgresql::firewall
  include profile::services::postgresql::logging
  contain profile::services::postgresql::server

  $install_munin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })
  $zabbix_servers = lookup('profile::zabbix::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  if($install_munin) {
    include ::profile::monitoring::munin::plugin::postgresql
  }

  if($zabbix_servers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    include ::profile::services::postgresql::users::zabbixagent
    package { 'zabbix-agent2-plugin-postgresql':
      ensure  => installed,
      require => Class['zabbix::agent'],
    }
  }
}
