# Creates DHCP pool based on data from hiera
define profile::services::dhcp::pool (
  Optional[String]                            $domain    = undef,
  Optional[Stdlib::IP::Address::V4::CIDR]     $cidr    = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet] $gateway = undef,
  Optional[Variant[Array[String], String]]    $range   = undef,
) {
  # Get the correct ID/Mask from the CIDR if it is supplied.
  if($cidr) {
    $network_id = ip_address($cidr)
    $mask = ip_netmask($cidr)

  # If no CIDR is supplied; grab the relevant config from the old hiera-keys.
  # TODO: Remove the hiera-lookup and simply base it on the supplied parameters.
  } else {
    $network_id = lookup("profile::networks::${name}::ipv4::id")
    $mask = lookup("profile::networks::${name}::ipv4::mask")
  }

  # Determine if a gateway should be configured
  # TODO: Remove the hiera-lookup and simply base it on the supplied parameters.
  $gateway_real = lookup("profile::networks::${name}::ipv4::gateway", {
    'default_value' => $gateway,
    'value_type'    => Optional[Stdlib::IP::Address::V4::Nosubnet],
  })

  # Determine if a range is to be configured:
  # TODO: Remove the hiera-lookup and simply base it on the supplied parameters.
  $range_real = lookup("profile::networks::${name}::ipv4::dynamicrange", {
    'default_value' => $range,
    'value_type'    => Optional[Variant[Array[String], String]],
  })

  # TODO: Remove the hiera-lookup and simply base it on the supplied parameters.
  if($domain) {
    $domain_real = $domain
  } else {
    # Determine if DHCP should hand out a domain-name.
    $include_name = lookup("profile::networks::${name}::dhcp::include_name", {
      'default_value' => false,
      'value_type'    => Boolean,
    })

    if ($include_name) {
      $domain_real = lookup("profile::networks::${name}::domain")
    } else {
      $domain_real = undef
    }
  }

  ::dhcp::pool { $name:
    network     => $network_id,
    mask        => $mask,
    range       => $range_real,
    gateway     => $gateway_real,
    domain_name => $domain_real,
  }
}
