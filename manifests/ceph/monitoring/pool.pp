# Configures all needed bits to graph the traffic/iops to/from a single ceph
# pool.
define profile::ceph::monitoring::pool {
  include ::profile::ceph::monitoring::collectors
  include ::profile::monitoring::munin::plugin::ceph::base
  include ::profile::systemd::reload

  $collectors = lookup('profile::monitoring::ceph::collectors', {
    'default_value' => false,
  })

  if($collectors) {
    $ensure = 'running'
    $enable = true
  } else {
    $ensure = 'stopped'
    $enable = false
  }

  # Configure systemd service
  file { "/lib/systemd/system/cephcollector.${name}.service":
    ensure  => file,
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Exec['ceph-systemd-reload'],
    content => epp('profile/cephcollector.service.epp', {
      'pool_name' => $name,
    })
  }

  # Make sure the service is running
  service { "cephcollector.${name}":
    ensure   => $ensure,
    enable   => $enable,
    provider => 'systemd',
    require  => [
      File["/lib/systemd/system/cephcollector.${name}.service"],
      File['/usr/local/sbin/ceph-collector.sh'],
      Exec['ceph-systemd-reload'],
    ],
  }

  if($collectors) {
    munin::plugin { "ceph_traffic_${name}":
      ensure  => link,
      target  => 'ceph_traffic_',
      require => File['/usr/share/munin/plugins/ceph_traffic_'],
      config  => ['user root'],
    }

    munin::plugin { "ceph_iops_${name}":
      ensure  => link,
      target  => 'ceph_iops_',
      require => File['/usr/share/munin/plugins/ceph_iops_'],
      config  => ['user root'],
    }
  }
}
