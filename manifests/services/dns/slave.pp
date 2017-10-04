# Installs and configures a DNS server.
class profile::services::dns::slave {
  $update_key = hiera('profile::dns::key::update')
  $transfer_key = hiera('profile::dns::key::transfer')

  $zones = hiera_hash('profile::dns::zones')
  $dns_zones = keys($zones)
  $servers = unique(values($zones))
  $master_ip = $servers.map |$server| {
    hiera("profile::dns::${server}::ipv4")
  }

  include ::dns::server

  ::dns::server::options{'/etc/bind/named.conf.options':
    dnssec_validation => 'no',
    dnssec_enable     => false,
  }

  ::dns::tsig { 'transfer':
    secret => $transfer_key,
    server => $master_ip,
  }

  ::profile::services::dns::zone { $dns_zones :
    type         => 'slave',
  }
}
