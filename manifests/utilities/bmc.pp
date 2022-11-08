# Manage iDRAC settings
class profile::utilities::bmc {

  $root_password = lookup('profile::bmc::root::password', String)
  #$bmc_ip = lookup('profile::bmc::ip', Stdlib::IP::Address::V4)
  $certificate = lookup('profile::bmc::cert', String)
  $private_key = lookup('profile::bmc::privatekey', String)
  $ntp_servers = lookup('profile::ntp::servers', Array[Stdlib::Fqdn])

  $certificate_path = '/etc/ssl/private/idrac.pem'
  $private_key_path = '/etc/ssl/private/idrac.key'

  bmc_user { 'root':
    password => $root_password,
  }

  bmc_ssl { 'IDRAC ssl':
    certificate_file => $certificate_path,
    certificate_key  => $private_key_path,
    require          => [
      File[$certificate_path],
      File[$private_key_path],
    ],
  }

  bmc_time {'ntnu-ntp':
    ntp_servers => $ntp_servers,
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
