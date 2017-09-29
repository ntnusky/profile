# This definition collects interface configuration from hiera, and configures
# the interface according to these settings.
define profile::baseconfig::configureinterface {
  $method = hiera("profile::interfaces::${name}::method")
  $secondary_routing = hiera("profile::interfaces::${name}::newtable", false)

  if($method == 'dhcp') {
    if($facts['networking']['interfaces'][$name]['ip']) {
      $address = $facts['networking']['interfaces'][$name]['ip']
      $netmask = $facts['networking']['interfaces'][$name]['netmask']
    } else {
      $address = undef
    }
  } else {
    $address = hiera("profile::interfaces::${name}::address", false)
    $netmask = hiera("profile::interfaces::${name}::netmask", '255.255.255.0')
  }
  $gateway = hiera("profile::interfaces::${name}::gateway", undef)

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
  if($secondary_routing) and ($address != undef) {
    $table_id = hiera("profile::interfaces::${name}::newtable::id")
    $netid = ip_network("${address}/${netmask}")

    network::routing_table { "table-${name}":
      table_id => $table_id,
    }->
    network::route { $name:
      ipaddress => [ '0.0.0.0', ip_address($netid), ],
      netmask   => [ '0.0.0.0', $netmask, ],
      gateway   => [ $gateway, false, ],
      table     => [ "table-${name}", "table-${name}",],
    }->
    network::rule { $name:
      iprule => ["from ${netid} lookup table-${name}", ],
    }
  }
}
