# Creates DNS zone
define profile::services::dns::zone {
  $dns_servers = hiera_array('profile::dns::servers::names')
  $dns_zones = hiera_array('profile::dns::zones')

  $servers = $dns_servers.map |$server| {
    "${server}.${dns_zones[0]}"
  }

  ::dns::zone { $name :
    nameservers  => $servers,
    allow_update => ['key update'],
    data_dir     => '/var/lib/bind/zones',
  }
}
