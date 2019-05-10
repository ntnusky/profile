# Configure networking with netplan
class profile::baseconfig::network::netplan (Hash $nics) {
  $dns_servers = lookup('profile::dns::nameservers', {
    'default_value' => undef,
  })
  $dns_search = lookup('profile::dns::searchdomain', {
    'default_value' => undef
  })

  $ethernets = $nics.reduce({}) | $memo, $n | {
    $nic = $n[0]
    $table_id = $nics[$nic]['tableid']
    if($table_id) {
      if($::facts['networking']['interfaces'][$nic]['ip']) {
        $net4id = $::facts['networking']['interfaces'][$nic]['network']
        $net4mask = netmask_to_masklen($::facts['networking']['interfaces'][$nic]['netmask'])
        $v4gateway = $nics[$nic]['ipv4']['gateway']
        $v4route = {
          'to'    => "${net4id}/${net4mask}",
          'via'   => $v4gateway,
          'table' => $table_id,
        }
        $v4policy = {
          'to'    => '0.0.0.0/0',
          'from'  => "${net4id}/${net4mask}",
          'table' => $table_id,
        }
      } else {
        $v4route = undef
        $v4policy = undef
      }
      if($::facts['networking']['interfaces'][$nic]['ip6']) {
        $net6id = $::facts['networking']['interfaces'][$nic]['network6']
        if($nics[$nic]['ipv6']) {
          $v6gateway = $nics[$nic]['ipv6']['gateway']
        } else {
          $v6gateway = 'fe80::1'
        }
        $v6route = {
          'to'    => "${net6id}/64",
          'via'   => $v6gateway,
          'table' => $table_id,
        }
        $v6policy = {
          'to'    => '::/0',
          'from'  => "${net6id}/64",
          'table' => $table_id,
        }
      } else {
        $v6route = undef
        $v6policy = undef
      }
      if($v4route) or ($v6route) {
        $routes = [ $v4route, $v6route ]
        $policies = [ $v4policy, $v6policy ]
      } else {
        $routes = undef
        $policies = undef
      }
    }
    $method = $nics[$nic]['ipv4']['method']
    if($method == 'dhcp') {
      $memo + { $nic => {
        'dhcp4'          => true,
        'routes'         => $routes,
        'routing_policy' => $policies,
      } }
    }
    elsif($method == 'manual') {
      $memo + $nic
    }
    else {
      if($nics[$nic]['ipv4']['address']) {
        $v4address = $nics[$nic]['ipv4']['address']
        $v4mask = netmask_to_masklen($nics[$nic]['ipv4']['netmask'])
        $v4cidr = [ "${v4address}/${v4mask}" ]
      } else {
        $v4cidr = []
      }

      if($nics[$nic]['ipv6']) {
        $v6cidr = [ $nics[$nic]['ipv6']['address'] ]
      } else {
        $v6cidr = []
      }

      $addresses = $v4cidr + $v6cidr
      $primary = $nics[$nic]['ipv4']['primary']
      $mtu = $nics[$nic]['mtu']

      if($primary) {
        $gateway = $nics[$nic]['ipv4']['gateway']
      } else {
        $gateway = undef
      }

      $memo + { $nic => {
        'addresses'      => $addresses,
        'gateway4'       => $gateway,
        'nameservers'    => {
          'addresses' => split($dns_servers, ' '),
          'search'    => [ $dns_search ],
        },
        'mtu'            => $nics[$nic]['mtu'],
        'routes'         => $routes,
        'routing_policy' => $policies,
      } }
    }
  }

  class { '::netplan':
    ethernets => $ethernets,
  }
}
