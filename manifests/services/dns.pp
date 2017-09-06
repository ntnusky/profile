# Installs and configures a DNS server.
class profile::services::dns {
  $dns_servers = hiera('profile::dns::servers')

  include ::dns::server

  dhs::server::options{'/etc/bind/named.conf.options':
    forwarders => $dns_servers,
  }
}
