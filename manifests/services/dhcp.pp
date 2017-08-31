# Installs and configures a DHCP server.
class profile::services::dhcp {
  $searchdomain = hiera('profile::dhcp::searchdomain')
  $dns_servers = hiera_array('profile::dns::servers')
  $interfaces = hiera_array('profile::interfaces')
  $networks = hiera_array('profile::networks')

  $omapi_name = hiera('profile::dhcp::omapi::name')
  $omapi_key = hiera('profile::dhcp::omapi::key')
  $omapi_port = hiera('profile::dhcp::omapi::port', 7911)

  $pxe_server = hiera('profile::dhcp::pxe::server')
  $pxe_file = hiera('profile::dhcp::pxe::file', 'pxelinux.0')

  class { '::dhcp':
    dnssearchdomains => [$searchdomain],
    interfaces       => $interfaces,
    nameservers      => $dns_servers,
    ntpservers       => $ntp_servers,
    omapi_key        => $omapi_key,
    omapi_name       => $omapi_name,
    omapi_port       => $omapi_port,
    pxeserver        => $pxe_server,
    pxefilename      => $pxe_file,
  }

  profile::services::dhcp::pool { $networks: }
}
