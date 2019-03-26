# Configure networking with netplan
class profile::baseconfig::network::netplan (Hash $nics) {
  $ethernets = $nics.reduce | $memo, $nic | {
    $method = $nics[$nic[0]]['ipv4']['method']
    if($method = 'dhcp') {
      $memo + { $nic[0] => { 'dhcp4' => true, } }
    }
  }

  class { '::netplan':
    ethernets => $ethernets,
  }
}
