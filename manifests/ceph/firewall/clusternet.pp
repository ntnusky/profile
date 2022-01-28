# Opens the firewall for communication on the cluster networks.
class profile::ceph::firewall::clusternet {
  require ::profile::baseconfig::firewall

  $cluster_networks = lookup('profile::ceph::cluster_networks', {
    'default_value' => false,
    'value_type'    => Variant[Array[Stdlib::IP::Address::V4::CIDR], Boolean],
  })
  $storage_interface = lookup('profile::interfaces::storagereplica', {
    'default_value' => false,
    'value_type'    => Variant[String, Boolean],
  })

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
