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
    # Get the IPv4-address in CIDR-format
    $ip4 = $data['ipv4']['address']
    $ip4cidr = netmask_to_masklen($data['ipv4']['netmask'])

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
      ipv4      => "${ip4}/${ip4cidr}",
      ipv6      => $v6,
      method    => $method_real,
      mtu       => ('mtu' in $data) ? { true => $data['mtu'], default => undef},
      tableid   => ('tableid' in $data) ? { true => $data['tableid'], default => undef},
      v4gateway => $data['ipv4']['gateway'],
    }
  }
}
