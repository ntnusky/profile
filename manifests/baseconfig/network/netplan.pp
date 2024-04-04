# Configure networking with netplan
class profile::baseconfig::network::netplan {
  $bonds = lookup('profile::baseconfig::network::bonds', {
    'default_value' => {},
    'value_type'    => Hash,
  })

  $ethernets = lookup('profile::baseconfig::network::interfaces', {
    'default_value' => {},
    'value_type'    => Hash,
  })

  $vlans = lookup('profile::baseconfig::network::vlans', {
    'default_value' => {},
    'value_type'    => Hash,
  })

  $bonds.each | $bond, $data | {
    # Retrieve the IPv4 address if it is provided
    if('ipv4' in $data and 'address' in $data['ipv4']) {
      $v4 = $data['ipv4']['address']
      $v4gw = $data['ipv4']['gateway']
    } else {
      $v4 = undef
      $v4gw = undef
    }

    # Get the IPv6-address if provided
    if('ipv6' in $data) {
      $v6 = $data['ipv6']['address']
    } else {
      $v6 = undef
    }

    ::profile::baseconfig::netplan::interface{ $bond:
      ipv4       => $v4,
      ipv6       => $v6,
      members    => $data['interfaces'],
      method     => $data['method'],
      mtu        => ('mtu' in $data) ? { true => $data['mtu'], default => undef},
      parameters => $data['parameters'],
      tableid    => ('tableid' in $data) ? { true => $data['tableid'], default => undef},
      v4gateway  => $v4gw,
    }
  }

  $ethernets.each | $if, $data | {
    # Retrieve the IPv4 address if it is provided
    if('ipv4' in $data) {
      # If netmask is provided, the address is probably not in CIDR format...
      if('netmask' in $data['ipv4']) {
        $ip4 = $data['ipv4']['address']
        $ip4cidr = netmask_to_masklen($data['ipv4']['netmask'])
        $v4 = "${ip4}/${ip4cidr}"

      # If the netmask is not provided, we expect the address to be in CIDR
      # format.
      } else {
        $v4 = $data['ipv4']['address']
      }
      $v4gw = $data['ipv4']['gateway']
      $v4alt = $data['ipv4']['alt_source']

    # Otherwise, skip IPv4-config.
    } else {
      $v4 = undef
      $v4gw = undef
      $v4alt = undef
    }

    if('ipv4' in $data and 'primary' in $data['ipv4']) {
      $primary = $data['ipv4']['primary']
    } else {
      $primary = false
    }

    # Get the IPv6-address if provided
    if('ipv6' in $data) {
      $v6 = $data['ipv6']['address']
      $v6alt = $data['ipv6']['alt_source']
    } else {
      $v6 = undef
      $v6alt = undef
    }

    # Determine the if-cofig-method
    if('method' in $data) {
      $method_real = $data['method']
    } else {
      warning(
        'Method within ipv4/ipv6 is deprecated. Place under interface instead')
      $method_real = $data['ipv4']['method']
    }

    ::profile::baseconfig::netplan::interface{ $if:
      alt_source_v4 => $v4alt,
      alt_source_v6 => $v6alt,
      ipv4          => $v4,
      ipv6          => $v6,
      method        => $method_real,
      mtu           => $data['mtu'],
      primary       => $primary,
      tableid       => $data['tableid'],
      v4gateway     => $v4gw,
    }
  }

  $vlans.each | $vlanname, $data | {
    # Retrieve the IPv4 address if it is provided
    if('ipv4' in $data) {
      $v4 = $data['ipv4']['address']
      $v4gw = $data['ipv4']['gateway']
    } else {
      $v4 = undef
      $v4gw = undef
    }

    # Get the IPv6-address if provided
    if('ipv6' in $data) {
      $v6 = $data['ipv6']['address']
    } else {
      $v6 = undef
    }

    ::profile::baseconfig::netplan::interface{ $vlanname:
      ipv4      => $v4,
      ipv6      => $v6,
      method    => $data['method'],
      mtu       => ('mtu' in $data) ? { true => $data['mtu'], default => undef},
      parent    => $data['parent'],
      priority  => ('priority' in $data) ? {
        true    => $data['priority'],
        default => 100,
      },
      tableid   => ('tableid' in $data) ? {
        true    => $data['tableid'],
        default => undef,
      },
      v4gateway => $v4gw,
      vlanid    => $data['vlanid'],
    }
  }
}
