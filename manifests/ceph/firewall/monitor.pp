# Opens the firewall for the ceph monitor.
class profile::ceph::firewall::monitor {
  require ::profile::baseconfig::firewall

  $ceph_public = lookup('profile::ceph::public_networks', {
    'variable_type' => Array,
    'default_value' => [],
  })
  $mgmtv4_nets = lookup('profile::networking::management::ipv4::prefixes', {
    'variable_type' => Array,
    'default_value' => [],
  })
  $mgmtv6_nets = lookup('profile::networking::management::ipv6::prefixes', {
    'variable_type' => Array,
    'default_value' => [],
  })
  $storage_interface = lookup('profile::interfaces::storage', String)

  # Allow ceph-cluster traffic
  $ceph_public.each | $net | {
    firewall { "200 accept incoming traffic for ceph monitor from ${net}":
      source  => $net,
      iniface => $storage_interface,
      proto   => 'tcp',
      dport   => [ '6789' ],
      action  => 'accept',
    }
  }

  # Allow traffic to the dashboard from the management networks.
  $mgmtv4_nets.each | $net | {
    firewall { "300 accept incoming traffic for ceph dashboard from ${net}":
      source  => $net,
      proto   => 'tcp',
      dport   => [ '7000' ],
      action  => 'accept',
    }
  }
  $mgmtv6_nets.each | $net | {
    firewall { "300 accept incoming traffic for ceph dashboard from ${net}":
      source   => $net,
      proto    => 'tcp',
      dport    => [ '7000' ],
      action   => 'accept',
      provider => 'ip6tables',
    }
  }
}
