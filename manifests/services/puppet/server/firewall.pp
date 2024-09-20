# Configures the firewall for puppetmasters. 
class profile::services::puppet::server::firewall {
  # The default-behavior is to allow puppet from the infrastructure networks, so
  # first we grab these lists.
  $infrav4 = lookup('profile::networking::infrastructure::ipv4::prefixes', {
    'value_type' => Array[Stdlib::IP::Address::V4::CIDR],
    'merge'      => 'unique',
    'default_value' => [],
  })
  $infrav6 = lookup('profile::networking::infrastructure::ipv6::prefixes', {
    'value_type'    => Array[Stdlib::IP::Address::V6::CIDR],
    'merge'         => 'unique',
    'default_value' => [],
  })

  # We also allow to specify networks manually, aso we try to grab the custom
  # lists. If the custom lists is not present, we use the infrastructure-lists
  # from above.
  $v4source = lookup('profile::puppet::clients::ipv4', {
    'default_value' => $infrav4,
    'value_type'    => Variant[
      Stdlib::IP::Address::V4::CIDR,
      Array[Stdlib::IP::Address::V4::CIDR],
    ]
  })
  $v6source = lookup('profile::puppet::clients::ipv6', {
    'default_value' => $infrav6,
    'value_type'    => Variant[
      Stdlib::IP::Address::V6::CIDR,
      Array[Stdlib::IP::Address::V6::CIDR],
    ]
  })

  # Finally punch the appropriate holes in the firewall.
  ::profile::baseconfig::firewall::service::custom { 'Puppetmaster':
    protocol => 'tcp',
    port     => 8140,
    v4source => $v4source,
    v6source => $v6source,
  }
}
