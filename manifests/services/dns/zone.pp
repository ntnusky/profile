# Creates DNS zone
define profile::services::dns::zone {
  $dns_servers = hiera_array('profile::dns::servers::names')
  $dns_updaters = hiera_array('profile::dns::updaters', [])

  ::dns::zone { $name :
    nameservers  => $dns_servers,
    allow_update => concat($dns_updaters, '127.0.0.1'),
  }
}
