# Configure networking with netplan
class profile::baseconfig::network::netplan {
  $dns_servers = lookup('profile::dns::nameservers', {
    'default_value' => undef,
  })
  $dns_search = lookup('profile::dns::searchdomain', {
    'default_value' => undef,
  })

  $ethernets = lookup('profile::baseconfig::network::interfaces', {
    'default_value' => {},
    'value_type'    => Hash,
  })

  $ethernets.each | $if, $data | {
    # Retrieve the IPv4 address if it is provided
    if('ipv4' in $data and 'address' in $['ipv4']) {
      # If netmask is provided, the address is probably not in CIDR format...
      if('netmask' in $data['ipv4']) {
        $ip4 = $data['ipv4']['address']
        $ip4cidr = netmask_to_masklen($data['ipv4']['netmask'])
        $v4 = "${ip4}/${ip4cidr}",

      # If the netmask is not provided, we expect the address to be in CIDR
      # format.
      } else {
        $v4 = $data['ipv4']['address']
      }
    
    # Otherwise, skip IPv4-config.
    } else {
      $v4 = undef,
    }

    # Get the IPv6-address if provided
    if('ipv6' in $data) {
      $v6 = $data['ipv6']['address']
    } else {
      $v6 = undef
    }

    # Determine the if-cofig-method
    if('method' in $data) {
      $method_real = $data['method']
    } else {
      warning('Specifying method withing ipv4/ipv6 is deprecated. ' +
        'Place under interface instead')
      $method_real = $data['ipv4']['method']
    }

    ::profile::baseconfig::netplan::interface{ $if:
      ipv4      => $v4,
      ipv6      => $v6,
      method    => $method_real,
      mtu       => ('mtu' in $data) ? { true => $data['mtu'], default => undef},
      tableid   => ('tableid' in $data) ? { true => $data['tableid'], default => undef},
      v4gateway => $data['ipv4']['gateway'],
    }
  }
}
