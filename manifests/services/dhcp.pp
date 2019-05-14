# Installs and configures a DHCP server.
class profile::services::dhcp {
  $searchdomain = lookup('profile::dhcp::searchdomain', Stdlib::Fqdn)
  $ntp_servers = lookup('profile::ntp::servers', Array[Stdlib::Fqdn])
  $interfaces = keys(lookup('profile::baseconfig::network::interfaces', Hash))
  $networks = lookup('profile::networks', Array[String])

  $omapi_name = lookup('profile::dhcp::omapi::name', String)
  $omapi_key = lookup('profile::dhcp::omapi::key', String)
  $omapi_port = lookup('profile::dhcp::omapi::port', {
    'value_type'    => Stdlib::Port,
    'default_value' => 7911
    })

  $man_if = lookup('profile::interfaces::management', String)
  $mip = $facts['networking']['interfaces'][$man_if]['ip']
  $management_ip = lookup("profile::baseconfig::network::interfaces.${man_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $mip
    })
  $pxe_server = lookup('profile::dhcp::pxe::server', {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $management_ip
    })
  $pxe_file = lookup('profile::dhcp::pxe::file', {
    'value_type'    => String,
    'default_value' => 'pxelinux.0'
    })

  $nameservers = lookup('profile::dns::resolvers', Array[Stdlib::IP::Address::V4])

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
