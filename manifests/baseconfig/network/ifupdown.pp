# Configure networking with ifupdown
class profile::baseconfig::network::ifupdown (Hash $nics) {
  $dns_servers = lookup('profile::dns::nameservers', {
    'default_value' => undef,
  })
  $dns_search = lookup('profile::dns::searchdomain', {
    'default_value' => undef,
  })

  # "Strikk og binders" DNS-conf for RHEL like systems
  if ($dns_servers) {
    $dns_server_array = split($dns_servers, ' ')
  }
  else {
    $dns_server_array = []
  }

  $dns_config = {
    dns1            => $dns_server_array[0],
    dns2            => $dns_server_array[1],
    dns3            => $dns_server_array[2],
    domain          => $dns_search,
    dns_nameservers => $dns_servers,
    dns_search      => $dns_search,
  }

  $nics.each | $nic, $params | {
    $v4gateway = $params['ipv4']['gateway']
    if ('ipv6' in $params) {
      $v6gateway = pick($params['ipv6']['gateway'],'fe80::1')
    } else {
      $v6gateway = 'fe80::1'
    }
    $method = $params['ipv4']['method']
    if($method == 'dhcp') {
      network::interface { "${nic}":
        interface   => $nic,
        enable_dhcp => true,
      }
    }
    else {
      # These will all default to undef if not present in the hash from hiera
      $v4address = $params['ipv4']['address']
      $v4netmask = $params['ipv4']['netmask']
      $primary = $params['ipv4']['primary']
      $mtu = $params['mtu']

      if($primary) {
        $gateway_real = $v4gateway
      } else {
        $gateway_real = undef
      }

      network::interface { "${nic}":
        interface => $nic,
        method    => $method,
        ipaddress => $v4address,
        netmask   => $v4netmask,
        gateway   => $gateway_real,
        mtu       => $mtu,
        *         => $dns_config,
      }
    }
    if($params['ipv6']) {
      $pattern = '^([\w:]+)\/(\d+)$'
      $v6address = regsubst($params['ipv6']['address'], $pattern, '\1')
      $v6netmask = regsubst($params['ipv6']['address'], $pattern, '\2')
      network::interface { "v6-${nic}":
        interface => $nic,
        method    => $method,
        family    => 'inet6',
        ipaddress => $v6address,
        netmask   => $v6netmask,
      }
    }

    $table_id = $params['tableid']
    if($table_id) {
      if($::facts['networking']['interfaces'][$nic]['ip']) {
        $net4id = $::facts['networking']['interfaces'][$nic]['network']
        $net4mask = $::facts['networking']['interfaces'][$nic]['netmask']
        $v4netids = ['0.0.0.0', $net4id]
        $v4masks = ['0.0.0.0', $net4mask]
        $v4gateways = [$v4gateway, false]
        $v4tables = ["table-${nic}", "table-${nic}"]
        $v4families = ['inet', 'inet']
        $v4rules = ["from ${net4id}/${net4mask} lookup table-${nic}"]
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
      if($::facts['networking']['interfaces'][$nic]['ip6']) {
        $net6id = $::facts['networking']['interfaces'][$nic]['network6']
        $v6netids = ['::', $net6id]
        $v6masks = ['::', 'ffff:ffff:ffff:ffff::']
        $v6gateways = [$v6gateway, false]
        $v6tables = ["table-${nic}", "table-${nic}"]
        $v6families = ['inet6', 'inet6']
        $v6rules = ["from ${net6id}/64 lookup table-${nic}"]
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

      network::routing_table { "table-${nic}":
        table_id => $table_id,
      }
      -> network::route { $nic:
        ipaddress => concat($v4netids, $v6netids),
        netmask   => concat($v4masks, $v6masks),
        gateway   => concat($v4gateways, $v6gateways),
        table     => concat($v4tables, $v6tables),
        family    => concat($v4families, $v6families),
      }
      -> network::rule { $nic:
        iprule => concat($v4rules, $v6rules),
        family => concat($v4rulef, $v6rulef),
      }
    }
  }
}
