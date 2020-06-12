# This class installs varios basic tools.
class profile::baseconfig::packages {
  $basepackages = lookup('profile::baseconfig::packages',{
    'value_type' => Array[String],
    'merge'      => 'unique',
  })

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
        package { 'megacli':
          ensure   => 'present',
          provider => 'rpm',
          source   => 'http://rpm.iik.ntnu.no/MegaCli-8.07.14-1.noarch.rpm',
        }
      }
      default: { fail("${::osfamiliy} not supported") }
    }
  }

  # Install a range of useful tools. Some mandatory; while others can be listed
  # in hiera.
  ensure_packages ( [
    'bc',
    'jq',
  ], {
    'ensure' => 'present',
  })
  ensure_packages ( $basepackages, {
    'ensure' => 'present',
  })

  # Install pip3 so that we can use it as an package-provider
  package { 'python3-pip':
    ensure => 'present',
  }

  # Install our homemade administration scripts
  file { '/usr/ntnusky':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0770',
  }
  vcsrepo { '/usr/ntnusky/tools':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/ntnusky/tools.git',
    revision => master,
    require  => File['/usr/ntnusky'],
  }
}
