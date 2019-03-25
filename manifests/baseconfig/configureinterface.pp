# This definition collects interface configuration from hiera, and configures
# the interface according to these settings.
define profile::baseconfig::configureinterface {
  $method = lookup("profile::interfaces::${name}::method")
  $v4gateway = lookup("profile::interfaces::${name}::gateway", {
    'default_value' => undef
  })
  $v6gateway = lookup("profile::interfaces::${name}::gateway6", {
    'default_value' => 'fe80::1',
    'value_type' => String,
  })
  $mtu = lookup("profile::interfaces::${name}::mtu", {
    'default_value' => undef 
  })

  $dns_servers = lookup('profile::dns::nameservers', {
    'default_value' => undef,
  })
  $dns_search = lookup('profile::dns::searchdomain', {
    'default_value' => undef
  })

  $staticv6 = lookup("profile::interfaces::${name}::ipv6::address", {
    'default_value' => false,
  })

  $distro = $facts['os']['release']['major']

  if($method == 'dhcp') {
    if($distro == '16.04') {
      network::interface { $name:
        enable_dhcp => true,
      }
    elsif($distro == '18.04') {
      class { '::netplan':
        ethernets => {
          $name => {
            'dhcp4' => true,
          }
        }
      }
    }
  } else {
    $address = lookup("profile::interfaces::${name}::address", {
      'default_value' => undef
    })
    $netmask = lookup("profile::interfaces::${name}::netmask", {
      'default_value' => undef
    })
    $primary = lookup("profile::interfaces::${name}::primary", {
      'default_value' => false
    })

    if($primary) {
      $gateway_real = $v4gateway
    } else {
      $gateway_real = undef
    }

    network::interface{ $name:
      method          => $method,
      ipaddress       => $address,
      netmask         => $netmask,
      gateway         => $gateway_real,
      dns_nameservers => $dns_servers,
      dns_search      => $dns_search,
      mtu             => $mtu,
    }
  }

  if($staticv6){
    $v6mask = lookup("profile::interfaces::${name}::ipv6::mask", {
      'default_value' => 64,
      'value_type'    => Integer,
    })

    concat::fragment { "interface-v6-${name}":
      target  => '/etc/network/interfaces',
      content => epp('profile/interface.ipv6.epp', {
        'interface' => $name,
        'v6address' => $staticv6,
        'v6mask'    => $v6mask,
      }),
      order   => 15,
    }
  }

  # Add extra routes based on hieradata
  $routes = lookup("profile::interfaces::${name}::routes", {
    'default_value' => false,
    'merge'         => 'hash',
  })
  if($routes) {
    $extranetids = $routes.map | $net, $gw | {
      ip_address($net)
    }
    $extramasks = $routes.map | $net, $gw | {
      ip_netmask($net)
    }
    $extragws = $routes.map | $net, $gw | {
      ip_address($gw)
    }
    $extrafamilies = $routes.map | $net, $gw | {
      'inet'
    }
    $extratables = $routes.map | $net, $gw | {
      'main'
    }
  } else {
    $extranetids = []
    $extramasks = []
    $extragws = []
    $extrafamilies = []
    $extratables = []
  }

  $table_id = lookup("profile::interfaces::${name}::tableid", {
    'default_value' => false
  })
  if ($table_id) {
    if($::facts['networking']['interfaces'][$name]['ip']) {
      $net4id = $::facts['networking']['interfaces'][$name]['network']
      $net4mask = $::facts['networking']['interfaces'][$name]['netmask']
      $v4netids = ['0.0.0.0', $net4id]
      $v4masks = ['0.0.0.0', $net4mask]
      $v4gateways = [$v4gateway, false]
      $v4tables = ["table-${name}", "table-${name}"]
      $v4families = ['inet', 'inet']
      $v4rules = ["from ${net4id}/${net4mask} lookup table-${name}"]
      $v4rulef = ['inet']
    } else {
      $v4netids = []
      $v4masks =  []
      $v4gateways = []
      $v4tables = []
      $v4families = []
      $v4rules = []
      $v4rulef = []
    }
    if($::facts['networking']['interfaces'][$name]['ip6']) {
      $net6id = $::facts['networking']['interfaces'][$name]['network6']
      $v6netids = ['::', $net6id]
      $v6masks = ['0', '64']
      $v6gateways = [$v6gateway, false]
      $v6tables = ["table-${name}", "table-${name}"]
      $v6families = ['inet6', 'inet6']
      $v6rules = ["from ${net6id}/64 lookup table-${name}"]
      $v6rulef = ['inet6']
    } else {
      $v6netids = []
      $v6masks =  []
      $v6gateways = []
      $v6tables = []
      $v6families = []
      $v6rules = []
      $v6rulef = []
    }

    network::routing_table { "table-${name}":
      table_id => $table_id,
    }
    -> network::route { $name:
      ipaddress => concat($v4netids, $v6netids, $extranetids),
      netmask   => concat($v4masks, $v6masks, $extramasks),
      gateway   => concat($v4gateways, $v6gateways, $extragws),
      table     => concat($v4tables, $v6tables, $extratables),
      family    => concat($v4families, $v6families, $extrafamilies),
    }
    -> profile::baseconfig::networkrule { $name:
      iprule => concat($v4rules, $v6rules),
      family => concat($v4rulef, $v6rulef),
    }
  } elsif ($routes) {
    network::route { $name:
      ipaddress => $extranetids,
      netmask   => $extramasks,
      gateway   => $extragws,
      table     => $extratables,
      family    => $extrafamilies,
    }
  }
}
