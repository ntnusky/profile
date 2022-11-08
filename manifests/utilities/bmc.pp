# Manage iDRAC settings
class profile::utilities::bmc {

  $root_password = lookup('profile::bmc::root::password', String)
  $bmc_ip = lookup('profile::bmc::ip', Stdlib::IP::Address::V4)
  $ca_cert = lookup('profile::bmc::ca_cert', String)
  $certificate = lookup('profile::bmc::cert', String)
  $private_key = lookup('profile::bmc::privatekey', String)
  $ntp_servers = lookup('profile::ntp::servers', Array[Stdlib::Fqdn])
  $dns_domain_name = lookup('profile::networks::bmc::domain', Stdlib::Fqdn)

  $ca_cert_path = '/etc/ssl/private/idrac_ca.pem'
  $certificate_path = '/etc/ssl/private/idrac.pem'
  $private_key_path = '/etc/ssl/private/idrac.key'

  $connection = {
    'bmc_username'    => 'root',
    'bmc_password'    => $root_password,
    'bmc_server_host' => $bmc_ip,
  }

  bmc_user { 'root':
    password => $root_password,
    callin   => true,
    ipmi     => true,
    link     => true,
    idrac    => 0x1ff,
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

  bmc_ssl { 'CA_chain':
    certificate_file => $ca_cert_path,
    type             => 2,
    require          => File[$ca_cert_path],
    *                => $connection,
  }
  -> bmc_ssl { 'IDRAC ssl':
    certificate_file => $certificate_path,
    certificate_key  => $private_key_path,
    require          => [
      File[$certificate_path],
      File[$private_key_path],
    ],
    *                => $connection,
  }

  bmc_time {'ntnu-ntp':
    ntp_servers => $ntp_servers,
    timezone    => 'Europe/Oslo',
  }

  file { $ca_cert_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $ca_cert,
  }

  file { $certificate_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $certificate,
  }

  file { $private_key_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $private_key_path,
  }
}
