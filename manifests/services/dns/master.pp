# Installs and configures a DNS server.
class profile::services::dns::master {
  $dns_zones = keys(hiera_hash('profile::dns::zones'))

  $update_key = hiera('profile::dns::key::update')
  $transfer_key = hiera('profile::dns::key::transfer')
  $forwarders = hiera('profile::dns::forwarders', [])

  include ::dns::server
  include ::profile::services::dns::firewall

  ::dns::server::options{'/etc/bind/named.conf.options':
    dnssec_validation => 'no',
    dnssec_enable     => false,
    forwarders        => $forwarders,
  }

  ::dns::tsig { 'update':
    secret => $update_key,
  }

  ::dns::tsig { 'transfer':
    secret => $transfer_key,
  }

  ::profile::services::dns::zone { $dns_zones : }
}
