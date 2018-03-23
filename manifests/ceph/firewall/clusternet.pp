# Opens the firewall for communication on the cluster networks.
class profile::ceph::firewall::clusternet {
  require ::profile::baseconfig::firewall

  $cluster_networks = hiera_array('profile::ceph::cluster_networks', false)
  $storage_interface = hiera('profile::interfaces::storagereplica', false)

  if($cluster_networks and $storage_interface) {
    $cluster_networks.each | $net | {
      firewall { "201 accept incoming traffic for ceph replication daemons from ${net}":
        source  => $net,
        iniface => $storage_interface,
        proto   => 'tcp',
        dport   => '6800-7300',
        action  => 'accept',
      }
    }
  }
}
