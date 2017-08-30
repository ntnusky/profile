# Installs and configures a DHCP server.
class profile::services::dhcp {
  $searchdomain = hiera('profile::dhcp::searchdomain')
  $dns_servers = hiera('profile::dns::servers')

  class { 'dhcp':
    dnssearchdomains => [$searchdomain],
    nameservers      => $dns_servers,
  }
}
