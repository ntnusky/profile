# This definition collects interface configuration from hiera, and configures
# the interface according to these settings.
define profile::baseconfig::configureinterface {
  $method = hiera("profile::interfaces::${name}::method")
  $address = hiera("profile::interfaces::${name}::address", false)
  $netmask = hiera("profile::interfaces::${name}::netmask", '255.255.255.0')
  $gateway = hiera("profile::interfaces::${name}::gateway", false)

  if($method == 'dhcp') {
    network::interface{ $name:
      method => $method,
    }
  } else {
    network::interface{ $name:
      method  => $method,
      address => $address,
      netmask => $netmask,
      gateway => $gateway,
    }
  }
}
