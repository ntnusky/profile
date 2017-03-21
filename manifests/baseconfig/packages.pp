# This class installs varios basic tools.


class profile::baseconfig::packages {

  $basepackages = hiera_array('profile::baseconfig::packages')

  # If it is an HP machine, install hpacucli.
  if($::bios_vendor == 'HP') {
    include ::hpacucli
  }

  if($::bios_vendor == 'Dell Inc.') {
    include ::srvadmin
    include ::hwraid

    $megaclipackages = [ 'megacli', 'mpt-status' ]
    package { $megaclipackages :
      ensure  => 'present',
      require => Class['::hwraid'],
    }
  }

  # Install a range of useful tools.
  package { $basepackages :
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
