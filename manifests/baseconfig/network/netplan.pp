# Configure networking with netplan
class profile::baseconfig::network::netplan (Hash $nics) {
  $dns_servers = lookup('profile::dns::nameservers', {
    'default_value' => undef,
  })
  $dns_search = lookup('profile::dns::searchdomain', {
    'default_value' => undef,
  })

  $ethernets = $nics.reduce({}) | $memo, $n | {
    $nic = $n[0]
    $table_id = $nics[$nic]['tableid']
    $mtu   = { 'mtu'   => $nics[$nic]['mtu'] }
    if ( $nic =~ /^lo/ ) {
      $match = {}
    } else {
      $mac = $::facts['networking']['interfaces'][$nic]['mac']
      $match = { 'match' => {'macaddress' => $mac} }
    }

    if($table_id) {
      if($::facts['networking']['interfaces'][$nic]['ip']) {
        $net4id = $::facts['networking']['interfaces'][$nic]['network']
        $net4mask = netmask_to_masklen($::facts['networking']['interfaces'][$nic]['netmask'])
        $v4gateway = $nics[$nic]['ipv4']['gateway']
        $v4defroute = {
          'to'    => '0.0.0.0/0',
          'via'   => $v4gateway,
          'table' => $table_id,
        }
        $v4route = {
          'to'      => "${net4id}/${net4mask}",
          'scope'   => 'link',
          'table'   => $table_id,
        }
        $v4policy = {
          'to'    => '0.0.0.0/0',
          'from'  => "${net4id}/${net4mask}",
          'table' => $table_id,
        }
      } else {
        $v4route = undef
        $v4defroute = undef
        $v4policy = undef
      }
      if($::facts['networking']['interfaces'][$nic]['ip6']) {
        $net6id = $::facts['networking']['interfaces'][$nic]['network6']
        if($nics[$nic]['ipv6']) {
          $v6gateway = $nics[$nic]['ipv6']['gateway']
        } else {
          $v6gateway = 'fe80::1'
        }
        $v6defroute = {
          'to'    => '::/0',
          'via'   => $v6gateway,
          'table' => $table_id,
        }
        $v6route = {
          'to'      => "${net6id}/64",
          'scope'   => 'link',
          'table'   => $table_id,
        }
        $v6policy = {
          'to'    => '::/0',
          'from'  => "${net6id}/64",
          'table' => $table_id,
        }
      } else {
        $v6route = undef
        $v6defroute = undef
        $v6policy = undef
      }
      if($v4route) or ($v6route) {
        $routes   = { 'routes'         => [ $v4route, $v4defroute, $v6defroute, $v6route ] }
        $policies = { 'routing_policy' => [ $v4policy, $v6policy ] }
      } else {
        $routes   = { 'routes'         => undef }
        $policies = { 'routing_policy' => undef }
      }
    } else {
        $routes   = { 'routes'         => undef }
        $policies = { 'routing_policy' => undef }
    }

    $common = $match + $mtu + $routes + $policies

    $method = $nics[$nic]['ipv4']['method']
    if($method == 'dhcp') {
      $dhcp = { 'dhcp4' => true }
      $memo + { $nic => $dhcp + $common }
    }
    elsif($method == 'manual') {
      $memo + { $nic => $common }
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
      } + $common }
    }
  }

  class { '::netplan':
    ethernets => $ethernets,
  }
}
