# Punch a hole in the firewall to allow all our management networks access to a 
# certain service.
define profile::baseconfig::firewall::service::management (
  Variant[Integer, Array[Integer], String] $port,
  String                                   $protocol,
) {
  require ::profile::baseconfig::firewall

  $mgmtnetworksv4 = lookup('profile::networking::management::ipv4::prefixes', {
    'value_type' => Array[Stdlib::IP::Address::V4::CIDR],
    'merge'      => 'unique',
  })
  $mgmtnetworksv6 = lookup('profile::networking::management::ipv6::prefixes', {
    'value_type'    => Array[Stdlib::IP::Address::V6::CIDR],
    'merge'         => 'unique',
    'default_value' => [],
  })

  $mgmtnetworksv4.each | $net | {
    firewall { "5 Accept service ${name} from ${net}":
      proto  => $protocol,
      dport  => $port,
      action => 'accept',
      source => $net,
    }
  }

  $mgmtnetworksv6.each | $net | {
    firewall { "5 Accept service ${name} from ${net}":
      proto    => $protocol,
      dport    => $port,
      action   => 'accept',
      source   => $net,
      provider => 'ip6tables',
    }
  }
}
