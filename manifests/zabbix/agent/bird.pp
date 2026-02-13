# Configures the zabbix-agent to monitor the bird daemons.
class profile::zabbix::agent::bird {
  include ::profile::zabbix::agent::sudo

  file { '/usr/local/sbin/monitor-bird-bgp.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    source => 'puppet:///modules/profile/zabbix/monitor-bird-bgp.py',
  }

  file { '/etc/zabbix/zabbix_agent2.d/userparam-bird.conf':
    ensure  => present,
    owner   => 'zabbix_agent',
    group   => 'zabbix_agent',
    mode    => '0644',
    content => join([
      'UserParameter=bird.status,sudo /usr/local/sbin/monitor-bird-bgp.py',
    ], '\n'),
    require => Package['zabbix-agent2'],
    notify  => Service['zabbix-agent2'],
  }
}
