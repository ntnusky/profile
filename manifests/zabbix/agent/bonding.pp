# Configures the zabbix-agent to monitor bonding-status 
class profile::zabbix::agent::bonding {
  include ::profile::zabbix::agent::sudo

  file { '/usr/local/sbin/bondstatus.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    source => 'puppet:///modules/profile/zabbix/bondstatus.py',
  }

  file { '/etc/zabbix/zabbix_agent2.d/userparam-bonding.conf':
    ensure  => present,
    owner   => 'zabbix_agent',
    group   => 'zabbix_agent',
    mode    => '0644',
    content => join([
      "UserParameter=bonding.status,sudo /usr/local/sbin/bondstatus.py",
    ], "\n"),
    require => Package['zabbix-agent2'],
    notify  => Service['zabbix-agent2'],
  }
}
