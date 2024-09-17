# Configures the zabbix-agent to monitor mysql backup-jobs
class profile::zabbix::agent::mysql {
  file { '/etc/zabbix/zabbix_agent2.d/userparam-mysql.conf':
    ensure  => present,
    owner   => 'zabbix_agent',
    group   => 'zabbix_agent',
    mode    => '0644',
    content => join([
      "UserParameter=mysql.backup.metrics,cat /var/cache/mysqlbackupstatus.json",
    ], "\n"),
    require => Package['zabbix-agent2'],
    notify  => Service['zabbix-agent2'],
  }
}
