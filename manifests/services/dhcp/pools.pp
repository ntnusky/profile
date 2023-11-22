# Configures the DHCP pools 
class profile::services::dhcp::pools {
  $networks = lookup('profile::networks', {
    'value_type' => Array[String],
    'merge'      => 'unique',
  })

  profile::services::dhcp::pool { $networks:}
}
