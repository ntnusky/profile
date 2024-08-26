# This class installs plugins needed for zabbix to monitor the ceph monitors.
class profile::ceph::zabbix::monitor {
  $servers = lookup('profile::zabbix::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  # Only install/configure zabbix if we actually are going to use zabbix
  if($servers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    $script = '/usr/local/sbin/get-osd-perfdata.py'

    file { $script:
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/profile/zabbix/get-osd-perfdata.py',
    }

    file { '/etc/zabbix/zabbix_agent2.d/userparam-ceph.conf':
      ensure  => present,
      owner   => 'zabbix_agent',
      group   => 'zabbix_agent',
      mode    => '0644',
      content => join([
        "UserParameter=ceph.custom.perf[*],${script} \$1 \$2 \$3",
        "UserParameter=ceph.custom.df,ceph df -f json",
      ], '\n'),
      require => Package['zabbix-agent2'],
      notify  => Service['zabbix-agent2'],
    }
  }
}
