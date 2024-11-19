# Opens the firewall for communication on the cluster networks.
class profile::ceph::firewall::clusternet {
  $replica_interface = lookup('profile::interfaces::storagereplica', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })

  if($replica_interface) {
    ::profile::firewall::custom { 'ceph-daemons-replicanet':
      hiera_key => 'profile::ceph::cluster_networks',
      port      => '6800-7300',
      interface => $replica_interface,
    }
  }
}
