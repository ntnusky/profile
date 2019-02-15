# Punch a hole in the firewall to allow all our infra-net access to a certain
# service.
define profile::baseconfig::firewall::service::infra (
  Variant[Integer, Array[Integer], String] $port,
  String                                   $protocol,
) {
  require ::profile::baseconfig::firewall

  $infrav4 = lookup('profile::networking::infrastructure::ipv4::prefixes', {
    'value_type' => Array[Stdlib::IP::Address::V4::CIDR],
    'merge'      => 'unique',
  })
  $infrav6 = lookup('profile::networking::infrastructure::ipv6::prefixes', {
    'value_type'    => Array[Stdlib::IP::Address::V6::CIDR],
    'merge'         => 'unique',
    'default_value' => [],
  })

  $infrav4.each | $net | {
    firewall { "5 Accept service ${name} from ${net}":
      proto  => $protocol,
      dport  => $port,
      action => 'accept',
      source => $net,
    }
  }

  $infrav6.each | $net | {
    firewall { "5 Accept service ${name} from ${net}":
      proto    => $protocol,
      dport    => $port,
      action   => 'accept',
      source   => $net,
      provider => 'ip6tables',
    }
  }
}
