# Creates DNS zone
define profile::services::dns::zone (
  $type = 'master',
) {
  $zones = hiera_hash('profile::dns::zones')
  $dns_servers = values($zones)
  $dns_zones = keys($zones)
  $masterserver = $zones[$name]
  $master_name = hiera("profile::dns::${masterserver}::name")

  if($type == 'slave') {
    $master_ip = hiera("profile::dns::${masterserver}::ip")
    $allow_update = undef
  } else {
    $master_ip = undef
    $allow_update = ['key update']
  }

  $servers = $dns_servers.map |$server| {
    hiera("profile::dns::${server}::ip")
  }

  ::dns::zone { $name :
    nameservers    => $servers,
    allow_update   => $allow_update,
    allow_transfer => ['key transfer'],
    data_dir       => '/var/lib/bind/zones',
    zone_type      => $type,
    slave_masters  => $master_ip,
    soa            => $master_name,
  }
}
