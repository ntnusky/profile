# Provides the base-configuration of ceph
class profile::ceph::base {
  # Determine the names/addresses of the ceph-mons, which might be a combination
  # of the old style controllers, or the new dedicated VM's.
  $controllernames = hiera_array('controller::names', [])
  $controlleraddresses = hiera_array('controller::storage::addresses', [])
  $ceph_mons = hiera_hash('profile::ceph::monitors', {})
  $ceph_mon_names = keys($ceph_mons)
  $ceph_mon_address = values($ceph_mons)
  $initial_names = join(concat($controllernames, $ceph_mon_names), ',')
  $initial_addresses = join(concat($controlleraddresses, $ceph_mon_address), ',')

  # Configure the CIDR's used for the ceph networks.
  $public_networks = hiera_array('profile::ceph::public_networks')
  $cluster_networks = hiera_array('profile::ceph::cluster_networks', undef)

  # Various settings
  $fsid = hiera('profile::ceph::fsid')
  $replicas =  hiera('profile::ceph::replicas', undef)
  $journal_size =  hiera('profile::ceph::journal::size', undef)
  $bluestore_cache_size = hiera('profile::ceph::bluestore::cache::size', undef)

  # Install the ceph repos first
  require ::ceph::repo

  class { 'ceph':
    fsid                  => $fsid,
    mon_initial_members   => $initial_names,
    mon_host              => $initial_addresses,
    osd_pool_default_size => $replicas,
    public_network        => $public_networks,
    cluster_network       => $cluster_networks,
  }

  ceph_config {
    'global/osd_journal_size': value     => $journal_size;
    'global/bluestore_cache_size': value => $bluestore_cache_size;
  }
}
