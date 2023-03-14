# Provides the base-configuration of ceph
class profile::ceph::base {
  # Determine the names/addresses of the ceph-mons
  $ceph_mons = lookup('profile::ceph::monitors', {
    'default_value' => {},
    'value_type'    => Variant[Hash[String,Stdlib::IP::Address], Hash],
  })
  $ceph_mon_names = join(keys($ceph_mons), ',')
  $ceph_mon_addresses = join(values($ceph_mons), ',')

  # Configure the CIDR's used for the ceph networks.
  $public_networks = lookup('profile::ceph::public_networks',
                            Array[Stdlib::IP::Address::V4::CIDR])
  $cluster_networks = lookup('profile::ceph::cluster_networks', {
    'default_value' => undef,
    'value_type'    => Optional[Array[Stdlib::IP::Address::V4::CIDR]],
  })

  # Various settings
  $fsid = lookup('profile::ceph::fsid')
  $replicas =  lookup('profile::ceph::replicas', {
    'default_value' => undef,
    'value_type'    => Optional[Integer],
  })
  $journal_size =  lookup('profile::ceph::journal::size', {
    'default_value' => undef,
    'value_type'    => Optional[Integer],
  })
  $bluestore_cache_size = lookup('profile::ceph::bluestore::cache::size', {
    'default_value' => undef,
    'value_type'    => Optional[Integer],
  })

  # Configure logging
  include ::profile::ceph::logging
  # Install the ceph repos first
  require ::profile::ceph::repo

  # As of 14.03.2023 the version 17.2.5 of ceph is not correctly packaged in the
  # ubuntu-repos; so we grab cephs own repos for focal (as they do not have a
  # jammy-one).
  if($::facts['os']['distro']['codename'] == 'jammy') {
    apt::key { 'ceph-focal':
      ensure => 'present',
      id     => '08B73419AC32B4E966C1A330E84AC2C0460F3994',
      source => 'https://download.ceph.com/keys/release.asc',
      before => Apt::Source['ceph-focal'],
    }
    ::apt::source { 'ceph-focal':
      ensure   => 'present',
      location => 'https://download.ceph.com/debian-quincy/',
      release  => 'focal',
      tag      => 'ceph',
    }
  }

  if($cluster_networks) {
    $cluster_networks_real = join($cluster_networks, ', ')
  } else {
    $cluster_networks_real = undef
  }

  class { '::ceph':
    fsid                  => $fsid,
    mon_initial_members   => $ceph_mon_names,
    mon_host              => $ceph_mon_addresses,
    osd_pool_default_size => $replicas,
    public_network        => join($public_networks, ', '),
    cluster_network       => $cluster_networks_real,
  }

  ceph_config {
    'global/osd_journal_size': value     => $journal_size;
    'global/bluestore_cache_size': value => $bluestore_cache_size;
  }
}
