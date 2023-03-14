# Abstraction for the ceph::repo class
class profile::ceph::repo {
  # As of 14.03.2023 the version 17.2.5 of ceph is not correctly packaged in the
  # ubuntu-repos; so we grab cephs own repos for focal (as they do not have a
  # jammy-one).
  if($::facts['os']['distro']['codename'] == 'jammy') {
    apt::key { 'ceph':
      ensure => 'present',
      id     => '08B73419AC32B4E966C1A330E84AC2C0460F3994',
      source => 'https://download.ceph.com/keys/release.asc',
      before => Apt::Source['ceph-focal'],
    }
    ::apt::source { 'ceph-focal':
      ensure   => 'present',
      location => 'https://download.ceph.com/debian-quincy/',
      release  => 'focal',
      tag      => 'ceph',
    }
  # If not jammy; we can use the default-repos for ceph
  } else {
    class { '::ceph::repo':
      ensure      => 'present', 
      enable_epel => false,
      enable_sig  => true,
    }
  }
}
