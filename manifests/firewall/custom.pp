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

  # Iterate through all prefixes (after removing any duplicates) to create
  # firewall-rules:
  unique($prefixes_all).each | $prefix | {
    # Check if it is legacy-network:
    if($prefix =~ Stdlib::IP::Address::V4::CIDR) {
      #$protocol = 'IPv4'
      $provider = 'iptables'
      $prefix_real = $prefix

    # Or if it is a single legacy IP:
    } elsif($prefix =~ Stdlib::IP::Address::V4::Nosubnet) {
      #$protocol = 'IPv4'
      $provider = 'iptables'
      $prefix_real = "${prefix}/32"

    # Or if it is a moden network:
    } elsif($prefix =~ Stdlib::IP::Address::V6::CIDR) {
      #$protocol = 'IPv6'
      $provider = 'ip6tables'
      $prefix_real = $prefix

    # Or if it is a single modern IP:
    } elsif($prefix =~ Stdlib::IP::Address::V6::Nosubnet) {
      #$protocol = 'IPv6'
      $provider = 'ip6tables'
      $prefix_real = "${prefix}/128"

    # Fail if it is something else...
    } else {
      fail("${prefix} is not an v4 or v6 address/CIDR")
    }

    # Create the firewall-rule for the given service.
    firewall { "500 accept traffic to ${name} from ${prefix}":
      proto    => $transport_protocol,
      dport    => $port,
      iniface  => $interface,
      action   => 'accept',
      #protocol => $protocol,
      provider => $provider,
      source   => $prefix_real,
    }
  }
}
