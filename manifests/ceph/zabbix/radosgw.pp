# This class installs plugins needed for zabbix to monitor the ceph monitors.
class profile::ceph::zabbix::monitor {
  $servers = lookup('profile::zabbix::agent::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  # Only install/configure zabbix if we actually are going to use zabbix
  if($servers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    file { '/usr/local/sbin/radosgw_usage.py':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/profile/zabbix/${script}',
    }

    file { '/etc/zabbix/zabbix_agent2.d/userparam-radosgw.conf':
      ensure  => present,
      owner   => 'zabbix_agent',
      group   => 'zabbix_agent',
      mode    => '0644',
      content => join([
        'UserParameter=radosgw.usage,/usr/local/sbin/radosgw_usage.py',
      ], "\n"),
      require => Package['zabbix-agent2'],
      notify  => Service['zabbix-agent2'],
    }

    sudo::conf { 'radosgw_sudoers':
      priority => 15,
      source   => 'puppet:///modules/profile/zabbix/radosgw_sudoers',
    }
  }
}
