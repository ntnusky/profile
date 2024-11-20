# Opens the firewall for ceph-daemons without a static bind port. (ceph-mgr,
# ceph-osd)
class profile::ceph::firewall::daemons {
  $storage_interface = lookup('profile::interfaces::storage', String)

  ::profile::firewall::custom { 'ceph-daemons':
    hiera_key => 'profile::ceph::public_networks',
    port      => '6800-7300',
    interface => $storage_interface,
  }
}
