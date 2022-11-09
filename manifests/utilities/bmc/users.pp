# Configure root user for iDRAC
class profile::utilities::bmc::users {

  $root_password = lookup('profile::bmc::root::password', String)
  $bmc_ip = lookup('profile::bmc::ip', Stdlib::IP::Address::V4)

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
}
