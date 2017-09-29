# Creates DNS zone
define profile::services::dns::zone (
  $type = 'master',
) {
  $dns_servers = hiera_array('profile::dns::servers::names')
  $dns_zones = hiera_array('profile::dns::zones')

  if($type == 'slave') {
    $master_ip = hiera('profile::dns::master::ip')
  } else {
    $master_ip = undef
  }
  $master_name = hiera('profile::dns::master::name')

  $servers = $dns_servers.map |$server| {
    "${server}.${dns_zones[0]}"
  }

  ::dns::zone { $name :
    nameservers    => $servers,
    allow_update   => ['key update'],
    allow_transfer => ['key transfer'],
    data_dir       => '/var/lib/bind/zones',
    zone_type      => $type,
    slave_masters  => $master_ip,
    soa            => $master_name,
  }
}
