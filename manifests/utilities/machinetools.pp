# This class installs vendor-specific HW management tools. 
class profile::utilities::machinetools {
  $machinetools = lookup('profile::baseconfig::machinetools::install', {
    'value_type'    => Boolean,
    'default_value' => true,
  })
  $manage_idrac = lookup('profile::bmc::manage', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  # If it is an HP machine, install hpacucli.
  if($::facts['dmi']['bios']['vendor'] == 'HP' and $machinetools) {
    include ::hpacucli
  }

  # If it is an Dell machine, install Dell's utilities
  if($::facts['dmi']['bios']['vendor'] == 'Dell Inc.' and $machinetools) {
    include ::srvadmin
    if $manage_idrac {
      include ::profile::utilities::bmc
    }
  }
}
