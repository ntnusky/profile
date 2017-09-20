# Creates DNS zone
define profile::services::dns::zone {
  $dns_servers = hiera_array('profile::dns::servers::names')
  $dns_zones = hiera_array('profile::dns::zones')
  $dns_updaters = hiera_array('profile::dns::updaters', [])

  $servers = $dns_servers.map |$server| {
    "${server}.${dns_zones[0]}"
  }

  ::dns::zone { $name :
    nameservers  => $servers,
    allow_update => concat($dns_updaters, '127.0.0.1'),
    data_dir     => '/var/lib/bind/zones',
    require      => File['/var/lib/bind/zones'],
  }
}
