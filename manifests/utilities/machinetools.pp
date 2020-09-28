# This class installs vendor-specific HW management tools. 
class profile::utilities::machinetools {
  $machinetools = lookup('profile::baseconfig::machinetools::install', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  # If it is an HP machine, install hpacucli.
  if($::bios_vendor == 'HP' and $machinetools) {
    include ::hpacucli
  }

  # If it is an Dell machine, install dell's utilities
  if($::bios_vendor == 'Dell Inc.' and $machinetools) {
    include ::srvadmin

    case $osfamily {
      'Debian': {
        include ::hwraid
        $megaclipackages = [ 'megacli', 'mpt-status' ]
        package { $megaclipackages :
          ensure  => 'present',
          require => [
            Class['::hwraid'],
            Class['::srvadmin'],
          ]
        }
      }
      'RedHat': {
        package { 'mpt-status':
          ensure   => 'present',
          provider => 'rpm',
          source   => 'http://rpm.iik.ntnu.no/mpt-status-1.2.0-4.el7.centos.x86_64.rpm',
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
