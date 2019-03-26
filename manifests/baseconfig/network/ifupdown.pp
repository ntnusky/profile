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
      $address = pick_default($params['ipv4']['address'], undef)
      $netmask = pick_default($params['ipv4']['netmask'], undef)
      $primary = pick_default($params['ipv4']['primary'], false)
      $mtu     = pick_default($params['mtu'], undef)

      if($primary) {
        $gateway = $params['ipv4']['gateway']
      } else {
        $gateway = undef
      }

      network::interface { $nic:
        method          => $method,
        ipaddress       => $address,
        netmask         => $netmask,
        gateway         => $gateway,
        dns_nameservers => $dns_servers,
        dns_search      => $dns_search,
        mtu             => $mtu
      }
    }
  }
}
