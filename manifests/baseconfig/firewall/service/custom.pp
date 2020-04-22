# Punch a hole in the firewall to allow some networks access to a certain 
# service.
define profile::baseconfig::firewall::service::custom (
  Variant[Integer, Array[Integer], String] $port,
  String                                   $protocol,
  Variant[Stdlib::IP::Address::V4::CIDR,
      Array[Stdlib::IP::Address::V4::CIDR]] $v4source = [],
  Variant[Stdlib::IP::Address::V6::CIDR,
      Array[Stdlib::IP::Address::V6::CIDR]] $v6source = [],
) {
  require ::profile::baseconfig::firewall

  $v4sources = [] + $v4source
  $v4sources.each | $net | {
    firewall { "5 Accept service ${name} from ${net}":
      proto  => $protocol,
      dport  => $port,
      action => 'accept',
      source => $net,
    }
  }

  $v6sources = [] + $v6source
  $v6sources.each | $net | {
    firewall { "5 Accept service ${name} from ${net}":
      proto    => $protocol,
      dport    => $port,
      action   => 'accept',
      source   => $net,
      provider => 'ip6tables',
    }
  }
}
