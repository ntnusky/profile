# Install and configure ceph-mon
class profile::ceph::monitor {
  $mon_key = lookup('profile::ceph::monitor_key', String)
  $mgr_key = lookup('profile::ceph::mgr_key', String)
  $admin_key = lookup('profile::ceph::admin_key', String)
  $bootstrap_osd_key = lookup('profile::ceph::osd_bootstrap_key', String)

  $installmunin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })
  $installsensu = lookup('profile::sensu::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  if($installmunin) {
    include ::profile::monitoring::munin::plugin::ceph
  }

  if ($installsensu) {
    include ::profile::sensu::plugin::ceph
    sensu::subscription { 'roundrobin:ceph': }
  }

  require ::profile::ceph::base
  include ::profile::ceph::firewall::daemons
  include ::profile::ceph::firewall::monitor
  include ::profile::ceph::haproxy::backend
  include ::profile::ceph::key::admin
  include ::profile::ceph::key::mgr
  include ::profile::ceph::zabbix::monitor

  File["/var/lib/ceph/mgr/ceph-${::hostname}"]
  -> Class['::profile::ceph::key::mgr'] 
  -> Service["ceph-mgr@${::hostname}"]

  ceph::mgr { $::hostname :
    # This sounds dangerous; but it really isnt. We enable cephx by creating a
    # key in ::profile::ceph::key::mgr
    authentication_type => 'none', 
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

  # We dont need this anymore. TODO: Remove at a later release when this has
  # been deployed on all platforms.
  file { '/usr/local/sbin/insightsKillSwitch.sh':
    ensure => absent,
  }
  cron { 'Ceph insights killswitch':
    ensure => absent,
  }

  anchor{'profile::ceph::monitor::end':}
}
