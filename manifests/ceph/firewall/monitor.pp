# Opens the firewall for the ceph monitor.
class profile::ceph::firewall::monitor {
  require ::profile::baseconfig::firewall

  $public_networks = hiera_array('profile::ceph::public_networks')
  $storage_interface = hiera('profile::interfaces::storage')

  $public_networks.each | $net | {
    firewall { "200 accept incoming traffic for ceph monitor from ${net}":
      source  => $net,
      iniface => $storage_interface,
      proto   => 'tcp',
      dport   => [ '6789' ],
      action  => 'accept',
    }
  }
}
