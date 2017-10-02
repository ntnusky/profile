# Installs and configures a DNS server.
class profile::services::dns::slave {
  $dns_forwarders = hiera('profile::dns::forwarders')
  $dns_zones = hiera_array('profile::dns::zones')

  $update_key = hiera('profile::dns::key::update')
  $transfer_key = hiera('profile::dns::key::transfer')
  $master_ip = hiera('profile::dns::master::ip')

  include ::dns::server
  include ::profile::services::dashboard::clients::dns

  ::dns::server::options{'/etc/bind/named.conf.options':
    forwarders        => $dns_forwarders,
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
