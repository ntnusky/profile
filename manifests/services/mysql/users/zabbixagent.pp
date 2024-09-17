# User and grats for the Zabbix Monitoring
class profile::services::mysql::users::zabbixagent {

  mysql_user { 'zabbix_agent@%':
    ensure        => 'present',
    plugin        => 'unix_socket',
  }
  ->mysql_grant { 'zabbix_agent@%/*.*':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['BINLOG MONITOR', 'PROCESS', 'SHOW DATABASES', 'SHOW VIEW'],
    table      => '*.*',
    user       => 'zabbix_agent@%',
  }
}
