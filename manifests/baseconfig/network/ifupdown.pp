# Configure networking with ifupdown
class profile::baseconfig::network::ifupdown (Hash $nics) {
  $dns_servers = lookup('profile::dns::nameservers', {
    'default_value' => undef,
  })
  $dns_search = lookup('profile::dns::searchdomain', {
    'default_value' => undef
  })

  $nics.each | $nic, $params | {
    $method = $params['ipv4']['method']
    if($method == 'dhcp') {
      network::interface { $nic:
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
        $v4gateway = $params['ipv4']['gateway']
      } else {
        $v4gateway = undef
      }

      network::interface { "v4-${nic]":
        interface       => $nic,
        method          => $method,
        ipaddress       => $v4address,
        netmask         => $v4netmask,
        gateway         => $v4gateway,
        dns_nameservers => $dns_servers,
        dns_search      => $dns_search,
        mtu             => $mtu
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
  }
}
