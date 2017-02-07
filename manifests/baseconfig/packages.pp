# This class installs varios basic tools.
class profile::baseconfig::packages {
  # If it is an HP machine, install hpacucli.
  if($::bios_vendor == 'HP') {
    include ::hpacucli
  }

  if($::bios_vendor == 'Dell Inc.') {
    include ::srvadmin
  }

  # Install a range of useful tools.
  package { [
    'atop',
    'bc',
    'ethtool',
    'fio',
    'git',
    'gdisk',
    'htop',
    'iotop',
    'iperf3',
    'locate',
    'pwgen',
    'qemu-utils',
    'screen',
    'sl',
    'sysstat',
    'tcpdump',
    'vim',
  ] :
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
