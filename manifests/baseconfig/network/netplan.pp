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
      if($params['ipv4']['address']) {
        $address = $params['ipv4']['address']
        $mask = netmask_to_masklen($params['ipv4']['netmask'])
        $cidr = "${address}/${mask}"
      } else {
        $cidr = undef
      }

      $primary = $params['ipv4']['primary']
      $mtu = $params['mtu']

      if($primary) {
        $gateway = $params['ipv4']['gateway']
      } else {
        $gateway = undef
      }

      $memo + { $nic[0] => {
        'addresses'   => $cidr,
        'gateway4'    => $gateway,
        'nameservers' => {
          'addresses' => split($dns_servers, ' ')
          'search'    => $dns_search,
        },
        'mtu'         => $params['ipv4']['mtu']
      }
  }

  class { '::netplan':
    ethernets => $ethernets,
  }
}
