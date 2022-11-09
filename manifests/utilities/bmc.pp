# Manage iDRAC settings
class profile::utilities::bmc {

  $root_password = lookup('profile::bmc::root::password', String)
  $bmc_ip = lookup('profile::bmc::ip', Stdlib::IP::Address::V4)
  $ca_cert = lookup('profile::bmc::ca_cert', String)
  $certificate = lookup('profile::bmc::cert', String)
  $private_key = lookup('profile::bmc::privatekey', String)
  $ntp_servers = lookup('profile::ntp::servers', Array[Stdlib::Fqdn])
  # TODO: Dette har vi ikke brukt for når bmc_network ikke virker for alt
  $dns_domain_name = lookup('profile::networks::bmc::domain', Stdlib::Fqdn)

  $manage_users = lookup('profile::bmc::manage::users', {
    'value_type'    => Boolean,
    'default_value' => true,
  })
  $manage_certs = lookup('profile::bmc::manage::certs', {
    'value_type'    => Boolean,
    'default_value' => true,
  })
  $manage_ntp = lookup('profile::bmc::manage::ntp', {
    'value_type'    => Boolean,
    'default_value' => true,
  })
  $manage_network = lookup('profile::bmc::manage::network', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  $ca_cert_path = '/etc/ssl/private/idrac_ca.pem'
  $certificate_path = '/etc/ssl/private/idrac.pem'
  $private_key_path = '/etc/ssl/private/idrac.key'

  $connection = {
    'bmc_username'    => 'root',
    'bmc_password'    => $root_password,
    'bmc_server_host' => $bmc_ip,
  }

  if $manage_users {
    bmc_user { 'root':
      password => $root_password,
      callin   => true,
      ipmi     => true,
      link     => true,
      idrac    => 0x1ff,
    }
  }

  if $manage_ntp {
    bmc_time {'ntnu-ntp':
      ntp_enable  => true,
      ntp_servers => $ntp_servers,
      timezone    => 'Europe/Oslo',
    }
  }

  # TODO: Dette virker ikke på iDRAC9 nyere enn 4.40.40.0 med gjeldende versjon av modulen
  if $manage_network {
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

  if $manage_certs {
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
}
