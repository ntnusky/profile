# Installs and configures a DHCP server.
class profile::services::dhcp {
  $searchdomain = hiera('profile::dhcp::searchdomain')
  $dns_servers = hiera_array('profile::dns::servers')
  $interfaces = hiera_array('profile::interfaces')
  $networks = hiera_array('profile::networks')

  $omapi_name = hiera('profile::dhcp::omapi::name')
  $omapi_key = hiera('profile::dhcp::omapi::key')
  $omapi_port = hiera('profile::dhcp::omapi::port', 7911)

  class { '::dhcp':
    dnssearchdomains => [$searchdomain],
    nameservers      => $dns_servers,
    interfaces       => $interfaces,
    omapi_key        => $omapi_key,
    omapi_name       => $omapi_name,
    omapi_port       => $omapi_port,
  }

  profile::services::dhcp::pool { $networks: }
}
