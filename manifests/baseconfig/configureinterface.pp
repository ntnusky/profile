# This definition collects interface configuration from hiera, and configures
# the interface according to these settings.
define profile::baseconfig::configureinterface {
  $method = hiera("profile::interfaces::${name}::method")
  $v4gateway = hiera("profile::interfaces::${name}::gateway", undef)
  $v6gateway = hiera("profile::interfaces::${name}::gateway6", 'fe80::1')

  if($method == 'dhcp') {
    network::interface { $name:
      enable_dhcp => true,
    }
  } else {
    $address = hiera("profile::interfaces::${name}::address", false)
    $netmask = hiera("profile::interfaces::${name}::netmask", '255.255.255.0')
    network::interface{ $name:
      ipaddress => $address,
      netmask   => $netmask,
      gateway   => $v4gateway,
    }
  }

  $table_id = hiera("profile::interfaces::${name}::newtable::id")
  if($facts['networking']['interfaces'][$name]['ip']) {
    $net4id = $facts['networking']['interfaces'][$name]['network']
    $v4netids = ['0.0.0.0', $net4id]
    $v4masks = ['0.0.0.0', $facts['networking']['interfaces'][$name]['netmask']]
    $v4gateways = [$v4gateway, false]
    $v4tables = ["table-${name}", "table-${name}"]
    $v4families = ['inet', 'inet']
    $v4rules = ["from ${net4id} lookup table-${name}"]
  } else {
    $v4netids = []
    $v4masks =  []
    $v4gateways = []
    $v4tables = []
    $v4families = []
    $v4rules = []
  }
  if($facts['networking']['interfaces'][$name]['ip6']) {
    $net6id = $facts['networking']['interfaces'][$name]['network6']
    $v6netids = ['::/0', $net6id]
    $v6masks = ['::/0', $facts['networking']['interfaces'][$name]['netmask6']]
    $v6gateways = [$v6gateway, false]
    $v6tables = ["table-${name}", "table-${name}"]
    $v6families = ['inet6', 'inet6']
    $v6rules = ["from ${net6id} lookup table-${name}"]
  } else {
    $v6netids = []
    $v6masks =  []
    $v6gateways = []
    $v6tables = []
    $v6families = []
    $v6rules = []
  }

  network::routing_table { "table-${name}":
    table_id => $table_id,
  }->
  network::route { $name:
    ipaddress => concat($v4netids, $v6netids),
    netmask   => concat($v4masks, $v6masks),
    gateway   => concat($v4gateways, $v6gateways),
    table     => concat($v4tables, $v6tables),
    familiy   => concat($v4families, $v6families),
  }->
  network::rule { $name:
    iprule => concat($v4rules, $v6rules),
  }
}
