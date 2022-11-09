# Manage iDRAC settings
class profile::utilities::bmc {

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

  # Does not work for Rx1x series (iDRAC 6)
  $manage_users_real = $::facts['dmi']['product']['name'] ? {
    /R[6789]10/ => false,
    default     => $manage_users,
  }
  # Does not work for Rx1x series (iDRAC 6)
  $manage_ntp_real = $::facts['dmi']['product']['name'] ? {
    /R[6789]10/ => false,
    default     => $manage_ntp,
  }
  # Does only work for Rx2x series (iDRAC 7)
  $manage_network_real = $::facts['dmi']['product']['name'] ? {
    /R[6789]20/ => $manage_network,
    default     => false,
  }

  if $manage_users_real {
    include ::profile::utilities::bmc::users
  }
  if $manage_certs {
    include ::profile::utilities::bmc::certs
  }
  if $manage_ntp_real {
    include ::profile::utilities::bmc::ntp
  }
  if $manage_network_real {
    include ::profile::utilities::bmc::networking
  }
}
