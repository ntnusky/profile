# Installs and configures a DNS server.
class profile::services::dns {
  $dns_forwarders = hiera('profile::dns::forwarders')
  $dns_zones = hiera_array('profile::dns::zones')

  include ::dns::server

  dns::server::options{'/etc/bind/named.conf.options':
    forwarders => $dns_forwarders,
  }

  ::profile::services::dns::zone { $dns_zones : }
}
