# Installs and configures a DHCP server.
class profile::services::dhcp {
  $searchdomain = hiera('profile::dhcp::searchdomain')
  $dns_servers = hiera_array('profile::dns::servers')
  $interfaces = hiera_array('profile::interfaces')

  class { 'dhcp':
    dnssearchdomains => [$searchdomain],
    nameservers      => $dns_servers,
    interfaces       => $interfaces,
  }
}
