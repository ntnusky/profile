# Opens the firewall for the ceph monitor.
class profile::ceph::firewall::monitor {
  $storage_interface = lookup('profile::interfaces::storage', String)

  ::profile::firewall::custom { 'ceph-monitor':
    hiera_key => 'profile::ceph::public_networks',
    port      => [3300, 6789],
    interface => $storage_interface,
  }
}
