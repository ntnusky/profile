# This class installs varios basic tools.
class profile::baseconfig::packages {
  # If it is an HP machine, install hpacucli.
  if($::bios_vendor == 'HP') {
    include ::hpacucli
  }

  # Install a range of useful tools.
  # Should we use: ensure_packages(['ksh','openssl'], {'ensure' => 'present'})
  # so that we can include nmap.
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
    'nmap',
    'pwgen',
    'qemu-utils',
    'screen',
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
