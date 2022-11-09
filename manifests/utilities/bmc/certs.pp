# Configure TLS Certs for iDRAC
class profile::utilities::bmc::certs {
  $root_password = lookup('profile::bmc::root::password', String)
  $bmc_ip = lookup('profile::bmc::ip', Stdlib::IP::Address::V4)
  $ca_cert = lookup('profile::bmc::ca_cert', String)
  $certificate = lookup('profile::bmc::cert', String)
  $private_key = lookup('profile::bmc::privatekey', String)

  $ca_cert_path = '/etc/ssl/private/idrac_ca.pem'
  $certificate_path = '/etc/ssl/private/idrac.pem'
  $private_key_path = '/etc/ssl/private/idrac.key'

  $connection = {
    'bmc_username'    => 'root',
    'bmc_password'    => $root_password,
    'bmc_server_host' => $bmc_ip,
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
  -> bmc_service { 'reset_idrac': }

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
    content => $private_key,
  }
}
