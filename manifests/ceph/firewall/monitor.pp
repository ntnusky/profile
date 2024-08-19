# Opens the firewall for the ceph monitor.
class profile::ceph::firewall::monitor {
  require ::profile::baseconfig::firewall
  include ::profile::ceph::firewall::rest

  $ceph_public = lookup('profile::ceph::public_networks', {
    'value_type' => Array[String],
    'default_value' => [],
  })
  $storage_interface = lookup('profile::interfaces::storage', String)

  # Allow ceph-cluster traffic
  $ceph_public.each | $net | {
    firewall { "200 accept incoming traffic for ceph monitor from ${net}":
      source  => $net,
      iniface => $storage_interface,
      proto   => 'tcp',
      dport   => [ '3300', '6789' ],
      action  => 'accept',
    }
  }
}
