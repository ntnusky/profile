# Configures the zabbix-agent to monitor puppet run-stats
class profile::zabbix::agent::puppet {
  file { '/usr/local/sbin/puppetStatus.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/zabbix/puppetStatus.py',
  }

  file { '/etc/zabbix/zabbix_agent2.d/userparam-puppet.conf':
    ensure  => present,
    owner   => 'zabbix_agent',
    group   => 'zabbix_agent',
    mode    => '0644',
    content => join([
      "UserParameter=puppet.metrics,/usr/local/sbin/puppetStatus.py \$1 \$2 \$3",
    ], "\n"),
    require => Package['zabbix-agent2'],
    notify  => Service['zabbix-agent2'],
  }
}
