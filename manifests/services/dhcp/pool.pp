# Creates DHCP pool based on data from hiera
define profile::services::dhcp::pool {
  $id = hiera("profile::networks::${name}::id")
  $mask = hiera("profile::networks::${name}::mask")
  $gateway = hiera("profile::networks::${name}::gateway")
  $range = hiera("profile::networks::${name}::range")

  ::dhcp::pool { "${name}":
    network => $id,
    mask    => $mask,
    range   => $range,
    gateway => $gateway,
  }
}
