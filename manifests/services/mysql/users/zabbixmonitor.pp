# User and grats for the Zabbix Monitoring
class profile::services::mysql::users::zabbixmonitor {
  $zbx_monitor_password = lookup('profile::mysqlcluster::zbx_monitor_password')

  mysql_user { 'zbx_monitor@%':
    ensure        => 'present',
    password_hash => mysql_password($zbx_monitor_password),
    plugin        => 'unix_socket',
  }
  ->mysql_grant { 'zbx_monitor@%/*.*':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['REPLICATION CLIENT', 'PROCESS', 'SHOW DATABASES', 'SHOW VIEW'],
    table      => '*.*',
    user       => 'zbx_monitor@%',
  }
}
