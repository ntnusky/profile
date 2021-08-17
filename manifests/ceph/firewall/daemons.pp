# Opens the firewall for ceph-daemons without a static bind port. (ceph-mgr,
# ceph-osd)
class profile::ceph::firewall::daemons {
  require ::profile::baseconfig::firewall

  $public_networks = lookup('profile::ceph::public_networks',
                            Array[Stdlib::IP::Address::V4::CIDR])
  $storage_interface = lookup('profile::interfaces::storage', String)

  $public_networks.each | $net | {
    firewall { "200 accept incoming traffic for ceph daemons from ${net}":
      source  => $net,
      iniface => $storage_interface,
      proto   => 'tcp',
      dport   => '6800-7300',
      action  => 'accept',
    }
  }
}
