# This definition collects interface configuration from hiera, and configures
# the interface according to these settings.
define profile::baseconfig::configureinterface {
  $method = hiera("profile::interfaces::${name}::method")
  $address = hiera("profile::interfaces::${name}::address", false)
  $netmask = hiera("profile::interfaces::${name}::netmask", '255.255.255.0')
  $gateway = hiera("profile::interfaces::${name}::gateway", undef)
  $secondary_routing = hiera("profile::interfaces::${name}::secondaryrouting",
      false)

  if($method == 'dhcp') {
    network::interface { $name:
      enable_dhcp => true,
    }
  } else {
    network::interface{ $name:
      ipaddress => $address,
      netmask   => $netmask,
      gateway   => $gateway,
    }
  }

  # If a separate routing-table is required for this interface:
  if($secondary_routing) {

  }
}
