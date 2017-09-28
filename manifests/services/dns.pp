# Installs and configures a DNS server.
class profile::services::dns {
  $dns_forwarders = hiera('profile::dns::forwarders')
  $dns_zones = hiera_array('profile::dns::zones')

  $update_key = hiera('profile::dns::key::update')
  $transfer_key = hiera('profile::dns::key::transfer')

  include ::dns::server
  include ::profile::services::dashboard::clients::dns

  ::dns::server::options{'/etc/bind/named.conf.options':
    forwarders        => $dns_forwarders,
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
