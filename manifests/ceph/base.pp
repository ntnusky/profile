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
    'value_type'    => Variant[Undef, Array[Stdlib::IP::Address::V4::CIDR]],
  })

  # Various settings
  $fsid = lookup('profile::ceph::fsid')
  $replicas =  lookup('profile::ceph::replicas', {
    'default_value' => undef,
    'value_type'    => Variant[Undef, Integer],
  })
  $journal_size =  lookup('profile::ceph::journal::size', {
    'default_value' => undef,
    'value_type'    => Variant[Undef, Integer],
  })
  $bluestore_cache_size = lookup('profile::ceph::bluestore::cache::size', {
    'default_value' => undef,
    'value_type'    => Variant[Undef, Integer],
  })

  # Install the ceph repos first
  require ::profile::ceph::repo

  if($cluster_networks) {
    $cluster_networks_real = join($cluster_networks, ', ')
  } else {
    $cluster_networks_real = undef
  }

  class { 'ceph':
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
