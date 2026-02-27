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

  # If it is an Dell machine, install dell's utilities
  if($::facts['dmi']['bios']['vendor'] == 'Dell Inc.' and $machinetools) {
    include ::srvadmin
    if $manage_idrac {
      include ::profile::utilities::bmc
    }

    case $::facts['os']['family'] {
      'Debian': {
        if ( versioncmp($facts['os']['release']['major'], '22.04') <= 0 ){
          require ::hwraid
          $megaclipackages = [ 'megacli', 'mpt-status' ]
          package { $megaclipackages :
            ensure  => 'present',
            require => [
              Class['::hwraid'],
              Class['::srvadmin'],
            ]
          }
        }
      }
      'RedHat': {
        package { 'ncurses-compat-libs':
          ensure   => 'present',
        }
        package { 'MegaCli':
          ensure   => 'present',
          provider => 'rpm',
          source   => 'http://rpm.iik.ntnu.no/MegaCli-8.07.14-1.noarch.rpm',
        }
      }
      default: { fail("${::osfamiliy} not supported") }
    }
  }
}
