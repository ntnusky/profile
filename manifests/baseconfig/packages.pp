# This class installs varios basic tools.
class profile::baseconfig::packages {
  if($::bios_vendor == 'HP') {
    include ::hpacucli
  }

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
    'sysstat',
    'tcpdump',
    'vim',
  ] :
    ensure => 'present',
  }
}
