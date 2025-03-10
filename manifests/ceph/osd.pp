# Installs and configures a ceph storage node
class profile::ceph::osd {
  $bootstrap_osd_key = lookup('profile::ceph::osd_bootstrap_key', String)
  $memory_target = lookup('profile::ceph::osd::memory::target', {
    'default_value' => 1610612736,
    'value_type'    => Integer,
  })

  $autolocation = lookup('profile::ceph::location::auto', {
    'default_value' => false,
    'value_type'    => Boolean,
  })
  $crush_location = lookup('profile::ceph::location', {
    'default_value' => undef,
    'value_type'    => Optional[String],
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

  if($autolocation and $crush_location) {
    fail('Cannot automatically set a manually supplied crush location')
  }

  if($autolocation and $::hostname =~ /.*\-([bg]?)(\d{2})\-(\d{2})\-(\d{2})/ ) {
    ceph_config { 'global/crush_location':
      value => "root=default row=row${2} rack=rack${2}-${3} host=${::hostname}",
    }
  } elsif ($crush_location) {
    ceph_config { 'global/crush_location':
      value => $crush_location,
    }
  } else {
    ceph_config {
      'global/crush_location': ensure => absent;
    }
  }
}
