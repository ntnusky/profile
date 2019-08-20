# Creates DHCP pool based on data from hiera
define profile::services::dhcp::pool {
  $id = lookup("profile::networks::${name}::ipv4::id")
  $domain = lookup("profile::networks::${name}::domain")
  $mask = lookup("profile::networks::${name}::ipv4::mask")
  $gateway = lookup("profile::networks::${name}::ipv4::gateway", {
    'default_value' => '',
    'value_type'    => Variant[Stdlib::IP::Address::V4, String],
  })
  $range = lookup("profile::networks::${name}::ipv4::dynamicrange", {
    'default_value' => '',
    'value_type'    => Variant[Array[String], String],
  })
  $include_name = lookup("profile::networks::${name}::dhcp::include_name", {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  if($include_name) {
    $domain_real = $domain
  } else {
    $domain_real = ''
  }

  ::dhcp::pool { "${name}":
    network     => $id,
    mask        => $mask,
    range       => $range,
    gateway     => $gateway,
    domain_name => $domain_real,
  }
}
