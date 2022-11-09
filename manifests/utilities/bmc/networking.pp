# Configure network settings for iDRAC
class profile::utilities::bmc::networking {

  $root_password = lookup('profile::bmc::root::password', String)
  $bmc_ip = lookup('profile::bmc::ip', Stdlib::IP::Address::V4)
  $dns_domain_name = lookup('profile::networks::bmc::domain', Stdlib::Fqdn)

  $connection = {
    'bmc_username'    => 'root',
    'bmc_password'    => $root_password,
    'bmc_server_host' => $bmc_ip,
  }

  bmc_network { 'network_settings':
    ip_source                 => 'dhcp',
    ipv4_dns_from_dhcp        => true,
    dns_domain_from_dhcp      => false,
    dns_domain_name_from_dhcp => false,
    dns_domain_name           => $dns_domain_name,
    dns_bmc_name              => $::hostname,
    *                         => $connection,
  }
}
