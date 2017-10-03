# Creates DNS zone
define profile::services::dns::zone (
  $type = 'master',
) {
  $zones = hiera_hash('profile::dns::zones')
  $dns_slaves = keys(hiera_hash('profile::dns::slaves', {}))
  $dns_zones = keys($zones)
  $masterserver = $zones[$name]
  $master_name = hiera("profile::dns::${masterserver}::name")

  if($type == 'slave') {
    $master_ip = hiera("profile::dns::${masterserver}::ipv4")
    $allow_update = undef
  } else {
    $master_ip = undef
    $allow_update = ['key update']
  }

  ::dns::zone { $name :
    nameservers    => concat($dns_slaves, $master_name),
    allow_update   => $allow_update,
    allow_transfer => ['key transfer'],
    data_dir       => '/var/lib/bind/zones',
    zone_type      => $type,
    slave_masters  => $master_ip,
    soa            => $master_name,
  }
}
