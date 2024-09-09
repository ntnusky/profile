# This class installs plugins needed for zabbix to monitor the ceph monitors.
class profile::ceph::zabbix::monitor {
  $servers = lookup('profile::zabbix::agent::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  # Only install/configure zabbix if we actually are going to use zabbix
  if($servers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    $scripts = [
      'get-osd-perfdata.py',
      'discover-ceph-deviceclasses.py',
      'discover-ceph-pools.py',
      'discover-ceph-osds.py',
    ]

    $scripts.each | $script | {
      file { "/usr/local/sbin/${script}":
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => "puppet:///modules/profile/zabbix/${script}",
      }
    }


    file { '/etc/zabbix/zabbix_agent2.d/userparam-ceph.conf':
      ensure  => present,
      owner   => 'zabbix_agent',
      group   => 'zabbix_agent',
      mode    => '0644',
      content => join([
        "UserParameter=ceph.custom.perf[*],/usr/local/sbin/get-osd-perfdata.py \$1 \$2 \$3",
        "UserParameter=ceph.custom.report[*],ceph report 2> /dev/null | jq '.[\"\$1\"]'",
        'UserParameter=ceph.custom.df,ceph df -f json',
        'UserParameter=ceph.custom.autoscale.status,ceph osd pool autoscale-status -f json',
        'UserParameter=ceph.discover.deviceclass,/usr/local/sbin/discover-ceph-deviceclasses.py',
        'UserParameter=ceph.discover.osds,/usr/local/sbin/discover-ceph-osds.py',
        'UserParameter=ceph.discover.pools,/usr/local/sbin/discover-ceph-pools.py',
      ], "\n"),
      require => Package['zabbix-agent2'],
      notify  => Service['zabbix-agent2'],
    }
  }
}
