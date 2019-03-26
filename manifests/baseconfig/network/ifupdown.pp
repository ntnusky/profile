# Configure networking with ifupdown
class profile::baseconfig::network::ifupdown (Hash $nics) {
  $nics.each | $nic, $params | {
    $method = $params['ipv4']['method']
    if($method == 'dhcp') {
      network::interface { $nic:
        enable_dhcp => true,
      }
    }
  }
}
