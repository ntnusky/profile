# Installs and configures a DHCP server.
class profile::services::dhcp {
  $searchdomain = hiera('profile::dhcp::searchdomain')
  $ntp_servers = hiera_array('profile::ntp::servers')
  $interfaces = hiera_array('profile::interfaces')
  $networks = hiera_array('profile::networks')

  $omapi_name = hiera('profile::dhcp::omapi::name')
  $omapi_key = hiera('profile::dhcp::omapi::key')
  $omapi_port = hiera('profile::dhcp::omapi::port', 7911)

  $man_if = hiera('profile::interfaces::management')
  $mip = $facts['networking']['interfaces'][$man_if]['ip']
  $management_ip = hiera("profile::interfaces::${man_if}::address", $mip)
  $pxe_server = hiera('profile::dhcp::pxe::server', $management_ip)
  $pxe_file = hiera('profile::dhcp::pxe::file', 'pxelinux.0')

  $nameservers = hiera_array('profile::dns::resolvers')

  include ::profile::services::dhcp::firewall

  class { '::dhcp':
    dnssearchdomains => [$searchdomain],
    interfaces       => $interfaces,
    nameservers      => $nameservers,
    ntpservers       => $ntp_servers,
    omapi_key        => $omapi_key,
    omapi_name       => $omapi_name,
    omapi_port       => $omapi_port,
    pxeserver        => $pxe_server,
    pxefilename      => $pxe_file,
  }

  profile::services::dhcp::pool { $networks:}
}
