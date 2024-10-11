# Install and configure ceph-mon
class profile::ceph::monitor {
  $mon_key = lookup('profile::ceph::monitor_key', String)
  $mgr_key = lookup('profile::ceph::mgr_key', String)
  $admin_key = lookup('profile::ceph::admin_key', String)
  $bootstrap_osd_key = lookup('profile::ceph::osd_bootstrap_key', String)

  require ::profile::ceph::base
  include ::profile::ceph::firewall::daemons
  include ::profile::ceph::firewall::monitor
  include ::profile::ceph::key::admin
  include ::profile::ceph::zabbix::monitor

  ceph::mgr { $::hostname :
    key        => $mgr_key,
    inject_key => true,
  }
  ceph::mon { $::hostname:
    key    => $mon_key,
    before => Anchor['profile::ceph::monitor::end']
  }

  Ceph::Key {
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
    before         => Anchor['profile::ceph::monitor::end']
  }
  ceph::key { 'client.bootstrap-osd':
    secret  => $bootstrap_osd_key,
    cap_mon => 'allow profile bootstrap-osd',
    before  => Anchor['profile::ceph::monitor::end']
  }

  sudo::conf { 'cephmon':
    priority => 15,
    source   => 'puppet:///modules/profile/sudo/cephmon_sudoers',
  }

  anchor{'profile::ceph::monitor::end':}
}
