# Add Zabbix montoring script

class profile::zabbix::agent::zookeeper {
  file { '/usr/local/sbin/zookeeper-stats.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/zabbix/zookeeper-stats.py',
  }

  file { '/etc/zabbix/zabbix_agent2.d/userparam-zookeeper.conf':
    ensure  => present,
    owner   => 'zabbix_agent',
    group   => 'zabbix_agent',
    mode    => '0644',
    content => join([
      "UserParameter=zookeeper.metrics,/usr/local/sbin/zookeeper-stats.py",
    ], "\n"),
    require => Package['zabbix-agent2'],
    notify  => Service['zabbix-agent2'],
  }
}
