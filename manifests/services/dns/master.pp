# Installs and configures a DNS server.
class profile::services::dns::master {
  $dns_zones = keys(hiera_hash('profile::dns::zones'))

  $update_key = hiera('profile::dns::key::update')
  $transfer_key = hiera('profile::dns::key::transfer')

  include ::dns::server
  
  ::dns::server::options{'/etc/bind/named.conf.options':
    dnssec_validation => 'no',
    dnssec_enable     => false,
  }

  ::dns::tsig { 'update':
    secret => $update_key,
  }

  ::dns::tsig { 'transfer':
    secret => $transfer_key,
  }

  ::profile::services::dns::zone { $dns_zones : }
}
