# Creates DHCP pool based on data from hiera
define profile::services::dhcp::pool (
  Optional[String]                            $domain    = undef,
  Optional[Stdlib::IP::Address::V4::CIDR]     $cidr    = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet] $gateway = undef,
  Optional[Variant[Array[String], String]]    $range   = undef,
) {
  # Get the correct ID/Mask from the CIDR if it is supplied.
  if($cidr) {
    $networkID = ip_address($cidr)
    $mask = ip_netmask($cidr)

  # If no CIDR is supplied; grab the relevant config from the old hiera-keys.
  } else {
    $networkID = lookup("profile::networks::${name}::ipv4::id")
    $mask = lookup("profile::networks::${name}::ipv4::mask")
  }

  # Determine if a gateway should be configured
  $gateway = lookup("profile::networks::${name}::ipv4::gateway", {
    'default_value' => $gateway,
    'value_type'    => Optional[Stdlib::IP::Address::V4::Nosubnet],
  })
  
  # Determine if a range is to be configured:
  $range = lookup("profile::networks::${name}::ipv4::dynamicrange", {
    'default_value' => $range,
    'value_type'    => Optional[Variant[Array[String], String]],
  })

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

  ::dhcp::pool { "${name}":
    network     => $networkID,
    mask        => $mask,
    range       => $range,
    gateway     => $gateway,
    domain_name => $domain_real,
  }
}
