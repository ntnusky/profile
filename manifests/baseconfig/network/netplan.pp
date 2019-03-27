# Configure networking with netplan
class profile::baseconfig::network::netplan (Hash $nics) {
  $dns_servers = lookup('profile::dns::nameservers', {
    'default_value' => undef,
  })
  $dns_search = lookup('profile::dns::searchdomain', {
    'default_value' => undef
  })

  $ethernets = $nics.reduce({}) | $memo, $nic | {
    $method = $nics[$nic[0]]['ipv4']['method']
    if($method == 'dhcp') {
      $memo + { $nic[0] => { 'dhcp4' => true, } }
    }
    else {
      if($nics[$nic[0]]['ipv4']['address']) {
        $v4address = $nics[$nic[0]]['ipv4']['address']
        $v4mask = netmask_to_masklen($nics[$nic[0]]['ipv4']['netmask'])
        $v4cidr = [ "${address}/${mask}" ]
      } else {
        $v4cidr = undef
      }

      if($nics[$nic[0]]['ipv6']['address']) {
        $v6cidr = $nics[$nic[0]]['ipv6']['address']
      } else {
        $v6cidr = undef
      }

      $addresses = $v4cidr + $v6cidr
      $primary = $nics[$nic[0]]['ipv4']['primary']
      $mtu = $nics[$nic[0]]['mtu']

      if($primary) {
        $gateway = $nics[$nic[0]]['ipv4']['gateway']
      } else {
        $gateway = undef
      }

      $memo + { $nic[0] => {
        'addresses'   => $addresses,
        'gateway4'    => $gateway,
        'nameservers' => {
          'addresses' => split($dns_servers, ' '),
          'search'    => [ $dns_search ],
        },
        'mtu'         => $nics[$nic[0]]['ipv4']['mtu']
      } }
    }
  }

  class { '::netplan':
    ethernets => $ethernets,
  }
}
