# Installs and configures a ceph storage node
class profile::ceph::osd {
  $bootstrap_osd_key = lookup('profile::ceph::osd_bootstrap_key', String)
  $memory_target = lookup('profile::ceph::osd::memory::target', {
    'default_value' => 1610612736,
    'value_type'    => Integer,
  })

  $row = lookup('profile::ceph::row', {
    'default_value' => undef,
    'value_type'    => Optional[Integer],
  })

  $rack = lookup('profile::ceph::rack', {
    'default_value' => undef,
    'value_type'    => Optional[Integer],
  })

  require ::profile::ceph::base
  include ::profile::ceph::firewall::daemons
  include ::profile::ceph::firewall::clusternet

  ceph::key {'client.bootstrap-osd':
    keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
    secret       => $bootstrap_osd_key,
  }

  sudo::conf { 'cephosd':
    priority => 15,
    source   => 'puppet:///modules/profile/sudo/cephosd_sudoers',
  }

  ceph_config {
    'global/osd_memory_target': value => $memory_target;
  }

  if($row) {
    $rowloc = "row=${row} "
  } else {
    $rowloc = ''
  }

  if($rack) {
    $racloc = "rack=${rack} "
  } else {
    $racloc = ''
  }

  if($rack or $row) {
    $hostloc = "host=${::hostname}"
    ceph_config { 'global/crush_location':
      value => "root=default ${rowloc}${racloc}${hostloc}",
    }
  } else {
    ceph_config {
      'global/crush_location': ensure => absent;
    }
  }
}
