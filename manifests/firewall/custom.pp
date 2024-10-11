# Opens the firewall for certain port(s) from a custom list of prefixes.
define profile::firewall::custom (
  Variant[Integer, Array[Integer], String] $port,
  Optional[String]                         $hiera_key = undef,
  Optional[String]                         $interface = undef,
  Array[Stdlib::IP::Address]               $prefixes = [],
  Enum['tcp', 'udp']                       $transport_protocol = 'tcp',
) {
  # If a hiera-key is supplied, grab the list from hiera and concatinate it with
  # the prefixes-list given as a parameter.
  if($hiera_key) {
    $prefixes_all = $prefixes + lookup($hiera_key, {
      'value_type' => Array[Stdlib::IP::Address],
    })
  } else {
    $prefixes_all = $prefixes
  }

  include ::profile::firewall

  unique($prefixes_all).each | $prefix | {
    if($prefix =~ Stdlib::IP::Address::V4::CIDR) {
      #$protocol = 'IPv4'
      $provider = 'iptables'
    } elsif($prefix =~ Stdlib::IP::Address::V6::CIDR) {
      #$protocol = 'IPv6'
      $provider = 'ip6tables'
    } else {
      fail("${prefix} is not an v4 or v6 CIDR")
    }

    firewall { "500 accept incoming ${name} from ${prefix}":
      proto    => $transport_protocol,
      dport    => $port,
      iniface  => $interface,
      jump     => 'accept',
      #protocol => $protocol,
      provider => $provider,
      source   => $prefix,
    }
  }
}
