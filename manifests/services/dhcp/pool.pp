# Creates DHCP pool based on data from hiera
define profile::services::dhcp::pool {
  $id = hiera("profile::networks::${name}::ipv4::id")
  $mask = hiera("profile::networks::${name}::ipv4::mask")
  $gateway = hiera("profile::networks::${name}::ipv4::gateway")
  $range = hiera("profile::networks::${name}::ipv4::dynamicrange", '')

  ::dhcp::pool { "${name}":
    network => $id,
    mask    => $mask,
    range   => $range,
    gateway => $gateway,
  }
}
