# Default firewall rules for haproxy
class profile::services::haproxy::firewall {
  $v4source = lookup('profile::haproxy::firewall::status::ipv4', {
    'default_value' => [],
    'value_type'    => Variant[
      Stdlib::IP::Address::V4::CIDR,
      Array[Stdlib::IP::Address::V4::CIDR],
    ],
  })
  $v6source = lookup('profile::haproxy::firewall::status::ipv6', {
    'default_value' => [],
    'value_type'    => Variant[
      Stdlib::IP::Address::V6::CIDR,
      Array[Stdlib::IP::Address::V6::CIDR],
    ],
  })

  ::profile::baseconfig::firewall::service::management { 'haproxy':
    port     => 9000,
    protocol => 'tcp',
  }

  ::profile::baseconfig::firewall::service::custon { 'haproxy-status-extra':
    port     => 9000,
    protocol => 'tcp',
    v4source => $v4source,
    v6source => $v6source,
  }
}
