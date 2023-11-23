# Configures the DHCP pools 
class profile::services::dhcp::pools {
  $networks = lookup('profile::networks', {
    'value_type' => Variant[Array[String], Hash],
  })

  if ( $networks =~ Array ) {
    profile::services::dhcp::pool { $networks:}
  } else {
    $networks.each | $networkname, $data | {
      profile::services::dhcp::pool { $networkname :
        cidr    => $data['ipv4']['cidr'], 
        domain  => $data['domain'],
        gateway => $data['ipv4']['gateway'],
        range   => $data['ipv4']['range'],
      }
    }
  }
}
