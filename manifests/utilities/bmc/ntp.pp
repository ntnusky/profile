# Configure NTP for iDRAC
class profile::utilities::bmc::ntp {
  $root_password = lookup('profile::bmc::root::password', String)
  $bmc_ip = lookup('profile::bmc::ip', Stdlib::IP::Address::V4)
  $ntp_servers = lookup('profile::ntp::servers', Array[Stdlib::Fqdn])

  $connection = {
    'bmc_username'    => 'root',
    'bmc_password'    => $root_password,
    'bmc_server_host' => $bmc_ip,
  }

  bmc_time {'ntnu-ntp':
    ntp_enable  => true,
    ntp_servers => $ntp_servers,
    timezone    => 'Europe/Oslo',
  }
}
